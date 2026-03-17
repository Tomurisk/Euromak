#include <lxpanel/plugin.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <X11/extensions/XInput2.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// gcc -shared -fPIC -o langswitcher.so langswitcher.c `pkg-config --cflags --libs lxpanel`

typedef struct {
    KeySym ks;
    const char *text;
} KeyMap;

static KeyMap keymap[] = {
    { XK_F15, "LT" },
    { XK_F16, "RO" },
    { XK_F17, "UA" },
    { 0, NULL }
};

typedef struct LangPlugin {
    GtkWidget *label;
    GtkWidget *event_box;
    LXPanel *panel;
    Display *dpy;
    int xi_opcode;
    char current_lang[8];
    char *lang_path;
} LangPlugin;

static const char *lang_file = "/tmp/emk_lang";

// Lookup
static const char* lookup(KeySym ks) {
    for (int i = 0; keymap[i].ks != 0; i++) {
        if (keymap[i].ks == ks)
            return keymap[i].text;
    }
    return NULL;
}

// Save file
static gboolean write_lang_file(gpointer data) {
    LangPlugin *plugin = data;
    FILE *f = g_fopen(plugin->lang_path, "w");
    if (f) {
        fprintf(f, "%s\n", plugin->current_lang);
        fclose(f);
    }
    return FALSE;
}

// UI update
static void update_display(LangPlugin *plugin) {
    char *markup = g_strdup_printf("<b>%s</b>",
                                   plugin->current_lang[0] ?
                                   plugin->current_lang : "??");
    gtk_label_set_markup(GTK_LABEL(plugin->label), markup);
    g_free(markup);
}

static void set_language(LangPlugin *plugin, const char *lang) {
    if (strcmp(lang, plugin->current_lang) != 0) {
        strncpy(plugin->current_lang, lang, 7);
        plugin->current_lang[7] = '\0';
        update_display(plugin);
        g_idle_add(write_lang_file, plugin);
    }
}

// Load file
static void load_lang_file(LangPlugin *plugin) {
    FILE *f = g_fopen(plugin->lang_path, "r");
    if (f) {
        char buf[16] = {0};
        if (fgets(buf, sizeof(buf), f)) {
            buf[strcspn(buf, "\n")] = '\0';
            strncpy(plugin->current_lang, buf, 7);
            plugin->current_lang[7] = '\0';
        }
        fclose(f);
    }
    update_display(plugin);
}

// File monitor callback
static void on_lang_file_changed(GFileMonitor *monitor,
                                 GFile *file,
                                 GFile *other_file,
                                 GFileMonitorEvent event_type,
                                 gpointer data)
{
    if (event_type == G_FILE_MONITOR_EVENT_CHANGED ||
        event_type == G_FILE_MONITOR_EVENT_CREATED ||
        event_type == G_FILE_MONITOR_EVENT_ATTRIBUTE_CHANGED)
    {
        load_lang_file((LangPlugin *)data);
    }
}

// XInput2 event loop
static gboolean poll_events(GIOChannel *chan, GIOCondition cond, gpointer data) {
    LangPlugin *plugin = data;
    XEvent ev;

    while (XPending(plugin->dpy)) {
        XNextEvent(plugin->dpy, &ev);

        if (ev.type == GenericEvent &&
            ev.xcookie.extension == plugin->xi_opcode &&
            XGetEventData(plugin->dpy, &ev.xcookie))
        {
            if (ev.xcookie.evtype == XI_RawKeyPress) {
                XIRawEvent *raw = ev.xcookie.data;
                int keycode = raw->detail;

                XkbStateRec state;
                XkbGetState(plugin->dpy, XkbUseCoreKbd, &state);

                int group = state.group;
                int level = (state.mods & ShiftMask) ? 1 : 0;

                KeySym ks = XkbKeycodeToKeysym(plugin->dpy,
                                               keycode,
                                               group, level);

                const char *lang = lookup(ks);
                if (lang)
                    set_language(plugin, lang);
            }

            XFreeEventData(plugin->dpy, &ev.xcookie);
        }
    }

    return TRUE;
}

// Cleanup
static void lang_destructor(gpointer data) {
    LangPlugin *plugin = data;
    if (plugin->dpy)
        XCloseDisplay(plugin->dpy);
    g_free(plugin->lang_path);
}

// Constructor
static GtkWidget *lang_constructor(LXPanel *panel, config_setting_t *settings) {
    LangPlugin *plugin = g_new0(LangPlugin, 1);
    plugin->panel = panel;

    plugin->lang_path = g_strdup(lang_file);

    plugin->dpy = XOpenDisplay(NULL);
    if (!plugin->dpy) {
        g_free(plugin);
        return NULL;
    }

    int event, error;
    if (!XQueryExtension(plugin->dpy, "XInputExtension",
                         &plugin->xi_opcode, &event, &error)) {
        XCloseDisplay(plugin->dpy);
        g_free(plugin);
        return NULL;
    }

    XIEventMask mask;
    unsigned char mask_data[XIMaskLen(XI_RawKeyPress)] = {0};

    mask.deviceid = XIAllMasterDevices;
    mask.mask_len = sizeof(mask_data);
    mask.mask = mask_data;

    XISetMask(mask.mask, XI_RawKeyPress);
    XISelectEvents(plugin->dpy, DefaultRootWindow(plugin->dpy), &mask, 1);
    XFlush(plugin->dpy);

    plugin->event_box = gtk_event_box_new();
    gtk_widget_set_has_window(plugin->event_box, FALSE);
    lxpanel_plugin_set_data(plugin->event_box, plugin, lang_destructor);

    plugin->label = gtk_label_new(NULL);
    gtk_widget_set_name(plugin->label, "LangSwitcher");
    gtk_container_add(GTK_CONTAINER(plugin->event_box), plugin->label);

    load_lang_file(plugin);

    // Monitor file changes
    GFile *gf = g_file_new_for_path(plugin->lang_path);
    GFileMonitor *mon = g_file_monitor_file(gf, G_FILE_MONITOR_NONE, NULL, NULL);
    g_signal_connect(mon, "changed", G_CALLBACK(on_lang_file_changed), plugin);
    g_object_unref(gf);

    int fd = ConnectionNumber(plugin->dpy);
    GIOChannel *gio = g_io_channel_unix_new(fd);
    g_io_add_watch(gio, G_IO_IN, (GIOFunc)poll_events, plugin);
    g_io_channel_unref(gio);

    gtk_widget_show_all(plugin->event_box);
    return plugin->event_box;
}

FM_DEFINE_MODULE(lxpanel_gtk, langswitcher)

LXPanelPluginInit fm_module_init_lxpanel_gtk = {
    .name = N_("Language Switcher"),
    .description = N_("Shows current keyboard language from F15/F16/F17 keys"),
    .new_instance = lang_constructor
};
