#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <X11/extensions/XInput2.h>
#include <stdio.h>
#include <stdlib.h>

// gcc mini_xev.c -o mini_xev $(pkg-config --cflags --libs x11 xi)

// -------------------------
// Define your key mappings
// -------------------------

typedef struct {
    KeySym ks;
    const char *text;
} KeyMap;

KeyMap keymap[] = {
    { XK_F15, "lt" },
    { XK_F16, "ro" },
    { XK_F17, "ua" },
    { 0, NULL }   /* end marker */
};

const char* lookup(KeySym ks) {
    for (int i = 0; keymap[i].ks != 0; i++) {
        if (keymap[i].ks == ks)
            return keymap[i].text;
    }
    return NULL;
}

// -------------------------

int main(void)
{
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "Cannot open display\n");
        exit(1);
    }

    int xi_opcode, event, error;

    if (!XQueryExtension(dpy, "XInputExtension", &xi_opcode, &event, &error)) {
        fprintf(stderr, "XInput extension not available.\n");
        exit(1);
    }

    Window root = DefaultRootWindow(dpy);

    // Select RawKeyPress only
    XIEventMask mask;
    unsigned char mask_data[XIMaskLen(XI_RawKeyPress)] = {0};

    mask.deviceid = XIAllMasterDevices;
    mask.mask_len = sizeof(mask_data);
    mask.mask = mask_data;

    XISetMask(mask.mask, XI_RawKeyPress);

    XISelectEvents(dpy, root, &mask, 1);
    XFlush(dpy);

    while (1) {
        XEvent ev;
        XNextEvent(dpy, &ev);

        if (ev.type == GenericEvent && ev.xcookie.extension == xi_opcode) {
            if (XGetEventData(dpy, &ev.xcookie)) {

                if (ev.xcookie.evtype == XI_RawKeyPress) {

                    XIRawEvent *raw = ev.xcookie.data;
                    int keycode = raw->detail;

                    // Get current keyboard state
                    XkbStateRec state;
                    XkbGetState(dpy, XkbUseCoreKbd, &state);

                    int group = state.group;
                    int level = (state.mods & ShiftMask) ? 1 : 0;

                    // Convert keycode → keysym
                    KeySym ks = XkbKeycodeToKeysym(dpy, keycode, group, level);

                    // Lookup in user-defined table
                    const char *msg = lookup(ks);
                    if (msg)
                        printf("%s\n", msg);
                }

                XFreeEventData(dpy, &ev.xcookie);
            }
        }
    }

    return 0;
}
