// Script Name: scr_camera_controller
// Purpose: Handles smooth camera zoom (centered on mouse) and middle-mouse drag for the main controller object’s Step Event.
//          Includes an alternative check for camera validity.
//
// Metadata:
//   Summary: Smoothly interpolate zoom around mouse, reposition camera.
//   Usage: obj_controller Step Event: camera_controller();
//   Parameters: none
//   Returns: void
//   Tags: [camera][behavior][utility]
//   Version: 1.3 — 2025-05-18 (Alternative camera validity check)
//   Dependencies: camera_set_view_size(), camera_set_view_pos(), device_mouse_x_to_gui()
//   Created: 2023-XX-XX
//   Modified: 2024-07-26 // Updated to 2025-05-23 for template adherence
//
// ---

/// @function camera_controller()
/// @description Handles smooth camera zoom (centered on mouse) and middle-mouse drag.
///              Intended for use in the Step Event of a controller object.
/// @usage obj_controller Step Event: camera_controller();
// No parameters for this function
/// @return {void}
//
function camera_controller() {
    // =========================================================================
    //    0. INITIALIZATION & SETUP
    // =========================================================================
    #region Initialization & Setup

    // 0.1. Imports & Cached Locals
    // -------------------------------------------------------------------------
    // Caching frequently accessed values or results of function calls
    // can improve performance, especially in Step events.
    var _cam      = view_camera[0]; // Get the camera ID for view 0
    var _rw       = room_width;
    var _rh       = room_height;
    var _gui_mx   = device_mouse_x_to_gui(0); // Mouse X in GUI coordinates
    var _gui_my   = device_mouse_y_to_gui(0); // Mouse Y in GUI coordinates

    // Instance variables from the calling object (e.g., obj_controller)
    // are assumed to be in scope and are used directly:
    // - zoom_level: Current zoom level of the camera.
    // - zoom_target: Target zoom level to smoothly interpolate towards.
    // - zoom_min: Minimum allowed zoom level.
    // - zoom_max: Maximum allowed zoom level.
    // - zoom_speed: Amount to change zoom_target per mouse wheel click.
    // - zoom_smooth: Smoothing factor for zoom interpolation (0 to 1).
    // - cam_x: Current camera X position in the room.
    // - cam_y: Current camera Y position in the room.
    // - dragging_camera: Boolean, true if camera is being dragged.
    // - drag_start_x: Mouse X position when drag started.
    // - drag_start_y: Mouse Y position when drag started.

    #endregion // Initialization & Setup

    // =========================================================================
    //    1. PRE-CONDITION CHECKS & VALIDATION
    // =========================================================================
    #region Pre-condition Checks & Validation

    // 1.1. Camera Validation
    // -------------------------------------------------------------------------
    // It's crucial to ensure the camera ID is valid before attempting to use it.
    // Valid camera IDs are typically non-negative integers. 'noone' (-4) is invalid.
    if (!is_real(_cam) || _cam < 0) {
        // Using show_debug_message for critical errors helps in debugging.
        // The '$' prefix allows for string interpolation.
        show_debug_message($"ERROR (camera_controller): Camera ID from view_camera[0] is invalid or 'noone' (Value: {0}). Cannot proceed." + _cam);
        exit; // Stop further execution of this script if camera is not valid.
    }

    #endregion // Pre-condition Checks & Validation

    // =========================================================================
    //    2. CONFIGURATION & CONSTANTS (IF ANY)
    // =========================================================================
    #region Configuration & Constants

    // Configuration for this script is primarily handled by instance variables
    // of the calling object (e.g., obj_controller's zoom_level, zoom_speed, etc.).
    // No script-local constants are defined here.

    #endregion // Configuration & Constants

    // =========================================================================
    //    3. CORE LOGIC
    // =========================================================================
    #region Core Logic

    // 3.1. Pre-Zoom: Record World Coordinates Under Mouse
    // -------------------------------------------------------------------------
    // To zoom centered on the mouse, we need to know what point in the
    // world is under the mouse cursor *before* the zoom is applied.
    var _world_mx_before_zoom = cam_x + (_gui_mx / zoom_level);
    var _world_my_before_zoom = cam_y + (_gui_my / zoom_level);

    // 3.2. Zoom Input
    // -------------------------------------------------------------------------
    // Adjust the zoom_target based on mouse wheel input.
    // clamp() ensures the zoom_target stays within defined min/max bounds.
    if (mouse_wheel_up()) {
        zoom_target = clamp(zoom_target + zoom_speed, zoom_min, zoom_max);
        show_debug_message($"DEBUG (camera_controller): Mouse Wheel Up. Zoom Target: {zoom_target}");
    }
    if (mouse_wheel_down()) {
        zoom_target = clamp(zoom_target - zoom_speed, zoom_min, zoom_max);
        show_debug_message($"DEBUG (camera_controller): Mouse Wheel Down. Zoom Target: {zoom_target}");
    }

    // 3.3. Smooth Zoom Interpolation
    // -------------------------------------------------------------------------
    // Smoothly interpolate the current zoom_level towards the zoom_target.
    // This creates a more visually appealing zoom effect than an instant change.
    if (abs(zoom_target - zoom_level) > 0.001) { // Check if a significant change is needed
        zoom_level += (zoom_target - zoom_level) * zoom_smooth;
    } else {
        zoom_level = zoom_target; // Snap to target if very close
    }

    // 3.4. Recalculate Camera Position for Centered Zoom
    // -------------------------------------------------------------------------
    // After zoom_level is updated, adjust cam_x and cam_y so that the
    // _world_mx_before_zoom/_world_my_before_zoom point remains under the mouse.
    cam_x = _world_mx_before_zoom - (_gui_mx / zoom_level);
    cam_y = _world_my_before_zoom - (_gui_my / zoom_level);

    // 3.5. Middle-Mouse Drag for Camera Panning
    // -------------------------------------------------------------------------
    // Allows the user to pan the camera by holding and dragging the middle mouse button.
    if (mouse_check_button_pressed(mb_middle)) {
        dragging_camera = true;
        drag_start_x    = _gui_mx; // Store initial mouse position for drag calculation
        drag_start_y    = _gui_my;
        show_debug_message($"DEBUG (camera_controller): Middle Mouse Pressed. Dragging Camera: {dragging_camera}. Start: ({drag_start_x},{drag_start_y})");
    }
    if (mouse_check_button_released(mb_middle)) {
        dragging_camera = false;
        show_debug_message($"DEBUG (camera_controller): Middle Mouse Released. Dragging Camera: {dragging_camera}");
    }

    if (dragging_camera) {
        var _delta_gui_mx = _gui_mx - drag_start_x; // Change in mouse X since last frame
        var _delta_gui_my = _gui_my - drag_start_y; // Change in mouse Y since last frame

        // Adjust camera position based on mouse movement, scaled by zoom level.
        // Dividing by zoom_level ensures panning feels consistent regardless of zoom.
        cam_x -= _delta_gui_mx / zoom_level;
        cam_y -= _delta_gui_my / zoom_level;
        show_debug_message($"DEBUG (camera_controller): Dragging. Delta: ({_delta_gui_mx},{_delta_gui_my}). New Cam Pos: ({cam_x},{cam_y})");

        // Update drag_start positions for the next frame's calculation.
        drag_start_x = _gui_mx;
        drag_start_y = _gui_my;
    }

    // 3.6. Apply Calculated Position and Size to Camera
    // -------------------------------------------------------------------------
    // Calculate the actual width and height of the camera view based on room dimensions
    // and the current zoom level.
    var _view_width_actual  = _rw / zoom_level;
    var _view_height_actual = _rh / zoom_level;

    // Update the camera's position and size.
    // These functions should work correctly if _cam is a valid ID.
    camera_set_view_pos(_cam, cam_x, cam_y);
    camera_set_view_size(_cam, _view_width_actual, _view_height_actual);

    #endregion // Core Logic

    // =========================================================================
    //    4. CLEANUP & RETURN VALUE
    // =========================================================================
    #region Cleanup & Return Value

    // 4.1. Cleanup (If Any)
    // -------------------------------------------------------------------------
    // No dynamic resources (e.g., data structures) were created in this script,
    // so no explicit cleanup is needed here.

    // 4.2. Return Value
    // -------------------------------------------------------------------------
    // This function does not return a value.
    return;

    #endregion // Cleanup & Return Value
}
