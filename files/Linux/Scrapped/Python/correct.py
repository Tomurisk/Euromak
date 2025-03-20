import keyboard

# Mapping of dead key combinations to desired output
dead_key_map = {
    ('4', 'i'): 'č',
    ('4', 'I'): 'Č'
}

# Variable to track if the dead key (4 from number bar) is active
active_dead_key = False

# Scan code for the `4` key on the number bar (not the keypad)
NUMBER_BAR_4_SCANCODE = 5  # Replace with actual scan code if this differs for your system

def on_key_event(event):
    global active_dead_key

    if event.event_type == 'down':
        if event.scan_code == NUMBER_BAR_4_SCANCODE:
            # Activate the pseudo-dead key and suppress '4'
            print("[DEBUG] Dead key '4' activated (number bar).")
            active_dead_key = True
            return False  # Suppress '4'
        elif active_dead_key:
            # Detect whether Shift is held
            is_uppercase = any(key in keyboard._pressed_events for key in ['shift', 'left shift', 'right shift'])
            key = event.name
            if is_uppercase and key.isalpha():
                key = key.upper()  # Convert to uppercase manually

            print(f"[DEBUG] Dead key combination: 4 + {key}")
            output = dead_key_map.get(('4', key))
            if output:
                print(f"[DEBUG] Output: {output}")
                keyboard.write(output)
                active_dead_key = False  # Reset dead key state
                return False  # Suppress original key
            else:
                print("[DEBUG] No mapping found for combination.")
        elif event.name not in ['shift', 'left shift', 'right shift']:  # Ignore Shift key
            # Reset the dead key if any other unrelated key is pressed
            print(f"[DEBUG] Resetting dead key. Key pressed: {event.name}")
            active_dead_key = False

    # Allow all other keys to function normally
    return True

# Hook the keyboard events and ensure suppression works
keyboard.hook(on_key_event, suppress=True)

print("Script is running... Press 'Ctrl+C' to exit.")
keyboard.wait()  # Keep the script running
