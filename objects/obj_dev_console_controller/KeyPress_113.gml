if (global.Debug.Console.Visible == true) { // Explicitly using == true for clarity, though just (global.Debug.Console.Visible) also works.
    // If the console is currently visible, hide it.
    global.Debug.Console.Visible = false;
    // Call the global function to update the visibility of all console UI elements.
    // This function is defined in the Create Event of this controller object.
    global.set_debug_elements_visibility(false);
    image_index = 0; // Assuming this object has a sprite to indicate on/off state.
    show_debug_message("F2 Pressed: Hiding console. global.Debug.Console.Visible is now " + string(global.Debug.Console.Visible));
} else {
    // If the console is currently hidden (because the above condition was false), show it.
    global.Debug.Console.Visible = true;
    // Call the global function to update the visibility of all console UI elements.
    global.set_debug_elements_visibility(true);
    image_index = 1; // Update sprite to indicate on state.
    show_debug_message("F2 Pressed: Showing console. global.Debug.Console.Visible is now " + string(global.Debug.Console.Visible));
}
// With an if/else structure, 'exit;' is not strictly necessary within the blocks
// to prevent both from running, as only one branch will ever be chosen.
// However, if there was other code *after* this if/else block in the same event that
// you wanted to skip, then 'exit;' could still be useful at the end of each branch.
