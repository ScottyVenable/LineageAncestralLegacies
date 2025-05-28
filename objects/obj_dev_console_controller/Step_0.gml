// The visibility of the debug console elements is directly tied to global.Debug.Console.Visible.
// The global.set_debug_elements_visibility function (defined in this object's Create Event)
// will find this controller instance and manage its UI elements based on the boolean value passed.

// Check if the global.Debug.Console struct and Visible property exist to prevent errors
// This is a safety check; these should ideally be initialized in obj_gameStart.
if (variable_global_exists("Debug") && is_struct(global.Debug) &&
    variable_struct_exists(global.Debug, "Console") && is_struct(global.Debug.Console) &&
    variable_struct_exists(global.Debug.Console, "Visible"))
{
    // Call the global function to set the visibility of debug elements.
    // This function handles finding the controller instance and its items.
    global.set_debug_elements_visibility(global.Debug.Console.Visible);
} else {
    // If the necessary global variables aren't set up, default to hiding the console elements
    // and log an error. This helps in debugging setup issues.
    // This situation should ideally not occur if obj_gameStart initializes these variables correctly.
    if (instance_exists(self)) { // Ensure we don't try to call if controller is being destroyed
        global.set_debug_elements_visibility(false);
    }
    show_debug_message("ERROR in obj_dev_console_controller Step: global.Debug.Console.Visible is not properly initialized. Ensure obj_gameStart sets this up.");
}