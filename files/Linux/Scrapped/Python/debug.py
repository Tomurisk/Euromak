import os
import keyboard

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
shift_pressed = False

def reset_state():
    """Reset all state variables."""
    global active_dead_key, shift_pressed
    active_dead_key = False
    shift_pressed = False

def simulate_keypress(output):
    """Simulate typing the output key using xdotool."""
    try:
        os.system(f"xdotool type --delay 0 '{output}'")  # Use xdotool to type the output character
    except Exception as e:
        print(f"[ERROR] Failed to send xdotool type: {e}")

def on_key_event(event):
    global active_dead_key, current_language, shift_pressed

    if event.event_type == 'down':
        # Detect when the dead key (4) is pressed
        if event.name == '4':
            print("[DEBUG] Dead key '4' activated.")
            active_dead_key = True
            return False  # Suppress the key '4'

        # Handle Shift key press
        if event.name in ['shift', 'left shift', 'right shift']:
            shift_pressed = True
            print("[DEBUG] Shift key pressed.")
            return True  # Allow Shift to function normally

        # Process dead key combinations
        if active_dead_key:
            key = event.name.upper() if shift_pressed else event.name
            dead_key_map = lt_dead_key_map if current_language == "LT" else ro_dead_key_map
            output = dead_key_map.get(('4', key))

            if output:
                print(f"[DEBUG] Dead key combination: 4 + {key.upper()} in {current_language} mode. Output: {output}")
                simulate_keypress(output)  # Use xdotool to type the output character
                reset_state()  # Reset dead key state
                return False  # Suppress the original key press
            else:
                print("[DEBUG] No mapping found for combination. Resetting state.")
                reset_state()
                return True  # Allow the key press to be processed normally

        # Handle language switching via Caps Lock
        if event.name == 'caps lock':
            # Toggle between LT and RO
            current_language = "RO" if current_language == "LT" else "LT"
            print(f"[DEBUG] Language switched to: {current_language}")
            reset_state()  # Ensure state reset after switching
            return False  # Suppress Caps Lock key

    elif event.event_type == 'up':
        # Reset shift state on key release
        if event.name in ['shift', 'left shift', 'right shift']:
            shift_pressed = False
            print("[DEBUG] Shift key released.")

    # Allow all other keys to function normally
    return True

# Hook the keyboard events
keyboard.hook(on_key_event, suppress=True)

print("Script is running... Press 'Ctrl+C' to exit.")
keyboard.wait()
