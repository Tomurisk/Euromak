import keyboard
import os
import platform
from pystray import Icon, MenuItem, Menu
from PIL import Image
import threading

# Mappings for Lithuanian (LT) and Romanian (RO)
lt_invokers = "itensoamrITENSOAMR"
keys_to_lt = ["č", "š", "ž", "ą", "ė", "ę", "į", "ų", "ū", "Č", "Š", "Ž", "Ą", "Ė", "Ę", "Į", "Ų", "Ū"]
ro_invokers = "renti[]RENTI{}"
keys_to_ro = ["ă", "â", "î", "ș", "ț", "«", "»", "Ă", "Â", "Î", "Ș", "Ț", "«", "»"]

# Build dead key mappings for both languages
lt_dead_key_map = {('4', lt_invokers[i]): keys_to_lt[i] for i in range(len(lt_invokers))}
ro_dead_key_map = {('4', ro_invokers[i]): keys_to_ro[i] for i in range(len(ro_invokers))}

# State variables
active_dead_key = False
current_language = "LT"  # Default language
NUMBER_BAR_4_SCANCODE = 5  # Replace with the actual scan code for `4` from number bar
shift_pressed = False
right_shift_pressed = False

# Tray Icon Variables
tray_icon = None
icon_path = ""

def update_tray_icon():
    """Update the tray icon based on the current language."""
    global tray_icon, icon_path
    if platform.system() == "Linux":
        icon_path = "lt.png" if current_language == "LT" else "ro.png"
    elif platform.system() == "Windows":
        icon_path = "lt.ico" if current_language == "LT" else "ro.ico"
    
    if os.path.exists(icon_path):
        image = Image.open(icon_path)
        tray_icon.icon = image
        tray_icon.update_menu()
    else:
        print(f"Icon file {icon_path} not found in the script directory.")

def toggle_language():
    """Toggle the current language and update tray icon."""
    global current_language
    current_language = "RO" if current_language == "LT" else "LT"
    update_tray_icon()

def on_quit(icon, item):
    """Exit the script."""
    icon.stop()

# Create and initialize the tray icon
def setup_tray_icon():
    global tray_icon
    image = Image.open("lt.png") if current_language == "LT" else Image.open("ro.png")
    menu = Menu(MenuItem("Toggle Language", lambda: toggle_language()),
                MenuItem("Quit", on_quit))
    tray_icon = Icon("KeyboardSwitcher", image, "Language Switcher", menu)
    tray_icon.run()

def on_key_event(event):
    global active_dead_key, current_language, shift_pressed, right_shift_pressed

    if event.event_type == 'down':
        # Track the state of Shift and Right Shift
        if event.name == 'shift' or event.name == 'left shift':
            shift_pressed = True
            right_shift_pressed = False
        elif event.name == 'right shift':
            right_shift_pressed = True

        # F1 acts as true Caps Lock functionality
        if event.name == 'f1':
            keyboard.press_and_release('caps lock')
            return False

        # Caps Lock toggles the language
        if event.name == 'caps lock':
            toggle_language()
            return False

        # F2 to output Shift + Enter
        if event.name == 'f2':
            keyboard.press_and_release('shift+enter')
            return False

        # Shift + Enter outputs a dollar sign ($)
        if event.name == 'enter' and shift_pressed:
            keyboard.write('$')
            return False

        # Check for Shift + Right Shift combination (both pressed simultaneously)
        if shift_pressed and right_shift_pressed:
            keyboard.write('“' if current_language == 'LT' else '”')
            shift_pressed = False
            right_shift_pressed = False
            return False

        # Special case for Right Shift: Output the "„" symbol
        if event.name == 'right shift' and not shift_pressed:
            keyboard.write('„')
            return False

        # Shift + `4` outputs a dollar sign
        if event.scan_code == NUMBER_BAR_4_SCANCODE and shift_pressed:
            keyboard.write('$')
            return False

        # Activate the dead key for `4` from number bar
        if event.scan_code == NUMBER_BAR_4_SCANCODE:
            active_dead_key = True
            return False

        # Handle dead key combinations
        elif active_dead_key:
            is_uppercase = any(key in keyboard._pressed_events for key in ['shift', 'left shift', 'right shift'])
            key = event.name
            if is_uppercase and key.isalpha():
                key = key.upper()

            dead_key_map = lt_dead_key_map if current_language == "LT" else ro_dead_key_map
            output = dead_key_map.get(('4', key))
            if output:
                keyboard.write(output)
                active_dead_key = False
                return False
        elif event.name not in ['shift', 'left shift', 'right shift', 'f2']:
            active_dead_key = False

    elif event.event_type == 'up':
        if event.name == 'shift' or event.name == 'left shift':
            shift_pressed = False
        elif event.name == 'right shift':
            right_shift_pressed = False

    return True

# Start tray icon in a separate thread
tray_thread = threading.Thread(target=setup_tray_icon, daemon=True)
tray_thread.start()

# Hook the keyboard events and ensure suppression works
keyboard.hook(on_key_event, suppress=True)

keyboard.wait()
