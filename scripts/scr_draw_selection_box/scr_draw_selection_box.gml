// Script Name: scr_draw_selection_box
// Purpose: Draws the translucent GUI-space selection rectangle while dragging.
//
// Metadata:
//   Summary: Render selection box from sel_start to current mouse position.
//   Usage: obj_controller Draw GUI Event: draw_selection_box(); // Assuming function is renamed
//   Parameters: none
//   Returns: void
//   Tags: [ui][selection][drawing]
//   Version: 1.1 — 2025-05-23 // Updated to conform to TEMPLATE_SCRIPT
//   Dependencies: device_mouse_x_to_gui(), draw_rectangle(), draw_set_color(), draw_set_alpha()
//   Created: 2025-05-18 (Assumed, based on previous version)
//   Modified: 2025-05-23 // Conformed to template
//
// ---

/// @function draw_selection_box()
/// @description Draws the translucent GUI-space selection rectangle if the user is dragging.
///              Intended for use in a Draw GUI event.
/// @usage obj_controller Draw GUI Event: draw_selection_box();
// No parameters for this function
/// @return {void}
function scr_draw_selection_box() {
    // =========================================================================
    // 0. IMPORTS & CACHES (Function-local)
    // =========================================================================
    #region 0. IMPORTS & CACHES
    // No specific imports or cached locals needed for this function beyond instance variables.
    // Assumes `is_dragging`, `sel_start_x`, and `sel_start_y` are accessible instance variables
    // from the calling object (e.g., obj_controller).\
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS (Function-local)
    // =========================================================================
    #region 1. VALIDATION & EARLY RETURNS
    // Only proceed if a drag operation is currently active.
    // TEMPORARILY COMMENTED OUT FOR TESTING
    /*
    if (!is_dragging) {
        return; // Exit early if not dragging, nothing to draw.
    }
    */
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS (Function-local)
    // =========================================================================
    #region 2. CONFIGURATION & CONSTANTS
    var _selection_color = global.SELECTION_BOX_PROPERTIES.COLOR; // The color of the selection box.
    var _selection_alpha = global.SELECTION_BOX_PROPERTIES.ALPHA;   // The transparency of the selection box (0.0 to 1.0).
    #endregion

    // =========================================================================
    // 3. CORE LOGIC: DRAW SELECTION BOX (Function-local)
    // =========================================================================
    #region 3. CORE LOGIC: DRAW SELECTION BOX
    // Get current mouse coordinates in GUI space.
    // These are used as the second corner of the selection rectangle.
    var _gui_mouse_x = device_mouse_x_to_gui(0);
    var _gui_mouse_y = device_mouse_y_to_gui(0);

    // Set drawing properties for the selection box.
    draw_set_color(_selection_color);
    draw_set_alpha(_selection_alpha);

    // DEBUG MESSAGE ADDED
    show_debug_message($"DEBUG scr_draw_selection_box: Drawing rect from ({sel_start_x},{sel_start_y}) to ({_gui_mouse_x},{_gui_mouse_y}). is_dragging: {is_dragging}");

    // Draw the rectangle.
    // min() and max() are used to ensure the rectangle is drawn correctly
    // regardless of the direction the mouse is dragged.
    draw_rectangle(
        min(sel_start_x, _gui_mouse_x), // Leftmost x-coordinate
        min(sel_start_y, _gui_mouse_y), // Topmost y-coordinate
        max(sel_start_x, _gui_mouse_x), // Rightmost x-coordinate
        max(sel_start_y, _gui_mouse_y), // Bottommost y-coordinate
        false // false = not an outline, true = outline only
    );

    // It's good practice to reset drawing properties if they were changed,
    // especially alpha, to avoid affecting other draw calls.
    draw_set_alpha(1); // Reset alpha to fully opaque.
    // draw_set_color(c_white); // Optionally reset color if it affects other drawing.
    #endregion

    // =========================================================================
    // 4. CLEANUP & RETURN (Function-local)
    // =========================================================================
    #region 4. CLEANUP & RETURN
    // No specific cleanup actions are needed beyond resetting alpha.
    // The function implicitly returns undefined (void).
    return;
    #endregion
}
