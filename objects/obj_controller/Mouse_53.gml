/// obj_controller – Event Global Left Pressed
///
/// Purpose:
///    Handles global left-click mouse input. Initiates drag selection.
///    Also handles single pop selection.
///
/// Metadata:
///    Summary:        Initiates drag selection or performs single selection.
///    Usage:          obj_controller Event: Mouse > Global Mouse > Global Left Pressed
///    Parameters:     none
///    Returns:        void
///    Tags:           [input][selection][drag_selection]
///    Version:        1.0
///    Dependencies:   device_mouse_x_to_gui(), device_mouse_y_to_gui(), scr_selection_controller()

// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
var _gui_mx = device_mouse_x_to_gui(0);
var _gui_my = device_mouse_y_to_gui(0);
#endregion

// =========================================================================
// 1. RESET PREVIOUS SELECTION STATE (Optional: Deselect all first on new click)
// =========================================================================
#region 1.1 Deselect All Pops (if desired behavior)
// with (obj_pop) {
//     selected = false;
// }
// selected_pop = noone; // From obj_controller
// if (instance_exists(global.ui_panel_instance)) { // Close existing panel
//     scr_selection_controller(noone);
// }
#endregion

// =========================================================================
// 2. INITIATE DRAG SELECTION
// =========================================================================
#region 2.1 Start Drag Box
is_dragging = true;
sel_start_x = _gui_mx;
sel_start_y = _gui_my;
show_debug_message($"DEBUG (obj_controller GLP): Drag started at ({sel_start_x}, {sel_start_y}). is_dragging = {is_dragging}");
#endregion

// =========================================================================
// 3. SINGLE CLICK SELECTION (This part is usually handled in Global Left *Released*
//    to differentiate a click from a drag. But if you want immediate feedback on press,
//    you might do a preliminary check here. For now, we focus on drag.)
// =========================================================================
// For a pure click (no drag), this logic would be better in Global Left Released.
// We'll handle the result of the drag (which could be a small drag treated as a click) there.

// At this point, scr_selection_controller(0) in your original setup for Global Left Pressed
// would likely be premature if you intend to allow dragging.
// We'll call scr_selection_controller in Global Left Released after the drag is complete.