// In an event that checks for key presses, e.g., obj_controller Step Event or Key Press C Event

if (keyboard_check_pressed(ord("C"))) {
    if (instance_exists(selected_pop)) { // Assuming selected_pop holds the ID of the currently selected pop
        with (selected_pop) {
            if (state == EntityState.WAITING) {
                // If already waiting, make it idle (and clear the wait flag)
                state = EntityState.IDLE;
                is_waiting = false;
                show_debug_message($"Pop {pop_identifier_string} C-Key: Toggled from WAITING to IDLE.");
            } else {
                // If not waiting, make it wait
                state = EntityState.WAITING;
                is_waiting = true; // Set the flag
                speed = 0; // Ensure it stops moving
                show_debug_message($"Pop {pop_identifier_string} C-Key: Toggled to WAITING state.");
            }
        }
    }
}