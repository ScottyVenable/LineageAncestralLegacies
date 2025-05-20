/// obj_pop - Step Event
///
/// Purpose:
///    Handles main pop behavior via state machine, separation from other pops,
///    and mouse hover detection for UI feedback.
///
/// Metadata:
///    Summary:         Manages pop states, separation, and hover.
///    Usage:           obj_pop Step Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [pop][behavior][state_machine][interaction]
///    Version:        1.2 - [Current Date] (Added mouse hover detection logic)
///    Dependencies:  scr_pop_behavior, scr_separate_pops, global.mouse_event_consumed_by_ui

// ============================================================================
// 1. CORE BEHAVIOR
// ============================================================================
#region 1.1 State Machine & Separation
scr_pop_behavior();  // Handles state-specific logic (idle, wander, forage, etc.)
scr_separate_pops(); // Handles pushing pops apart to prevent excessive overlap
#endregion

// ============================================================================
// 2. MOUSE HOVER DETECTION
// ============================================================================
#region 2.1 Mouse Hover Logic
// This logic determines if the mouse cursor is currently over this pop instance.
// It considers the pop's bounding box, which is affected by its sprite, scale, and position.

// Get current mouse position in room coordinates.
// device_mouse_x/y(0) is generally preferred for GUI-independent mouse position,
// but for collision with room objects, mouse_x/y (which are room-relative) are fine
// unless your view/port setup is complex. Let's stick to mouse_x/y for room objects.
var _mouse_check_x = mouse_x; // GameMaker's built-in mouse_x (room coordinates)
var _mouse_check_y = mouse_y; // GameMaker's built-in mouse_y (room coordinates)

// Check if the mouse position is within the pop's current bounding box.
// bbox_left, bbox_top, bbox_right, bbox_bottom are built-in variables that
// reflect the instance's collision mask's extent in the room, considering scale.
if (point_in_rectangle(_mouse_check_x, _mouse_check_y, bbox_left, bbox_top, bbox_right, bbox_bottom) &&
    !global.mouse_event_consumed_by_ui) { // Only register hover if UI hasn't "eaten" the mouse event
    is_mouse_hovering = true;
    
    // Optional: Change mouse cursor to indicate interactivity
    // window_set_cursor(cr_handpoint); // Make sure cr_handpoint is a valid cursor constant
} else {
    is_mouse_hovering = false;
    
    // Optional: Reset mouse cursor if this pop was the one that set it to cr_handpoint
    // This can be tricky if multiple objects can change the cursor. A more robust cursor
    // management system might be needed for complex UIs.
    // For now, let's assume the default cursor is restored elsewhere or not managed here.
    // Example:
    // if (window_get_cursor() == cr_handpoint && !instance_position(mouse_x, mouse_y, obj_pop)) { // if mouse is no longer over *any* pop
    //     window_set_cursor(cr_default);
    // }
}
#endregion

// ============================================================================
// 3. DEPTH SORTING (Can also be in End Step or Draw Begin for some effects)
// ============================================================================
#region 3.1 Update Depth
if (state != PopState.FORAGING) {
    depth = -y;
}
#endregion
