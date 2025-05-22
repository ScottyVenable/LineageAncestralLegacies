/// scr_camera_controller.gml
///
/// Purpose:
///    Handles smooth camera zoom (centered on mouse), middle-mouse drag
///    for the main controller object’s Step Event.
///    Includes an alternative check for camera validity.
///
/// Metadata:
///    Summary:         Smoothly interpolate zoom around mouse, reposition camera.
///    Usage:           obj_controller Step Event: scr_camera_controller();  
///    Parameters:    none  
///    Returns:         void  
///    Tags:            [camera][behavior][utility]  
///    Version:         1.3 — 2025-05-18 (Alternative camera validity check)
///    Dependencies:  camera_set_view_size(), camera_set_view_pos(), device_mouse_x_to_gui()

function scr_camera_controller() {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region Imports & Cached Locals
    var _cam      = view_camera[0]; // Get the camera ID for view 0
    var _rw       = room_width;     
    var _rh       = room_height;
    var _gui_mx   = device_mouse_x_to_gui(0);
    var _gui_my   = device_mouse_y_to_gui(0);
    
    // Instance variables from obj_controller are assumed to be in scope:
    // zoom_level, zoom_target, zoom_min, zoom_max, zoom_speed, zoom_smooth
    // cam_x, cam_y
    // dragging_camera, drag_start_x, drag_start_y
    #endregion

    // =========================================================================
    // 0.1 CAMERA VALIDATION (Alternative Check)
    // =========================================================================
    #region Camera Validation
    // Alternative check if camera_exists() is not available/working:
    // Valid camera IDs are usually non-negative. 'noone' is -4.
    if (!is_real(_cam) || _cam < 0) { // Check if _cam is not a valid positive number or zero
        show_debug_message($"ERROR (scr_camera_controller): Camera ID from view_camera[0] is invalid or 'noone' (Value: {_cam}). Cannot proceed.");
        exit; // Stop further execution if camera is not valid
    }
    #endregion

    // =========================================================================
    // 1. CONFIGURATION & CONSTANTS (Handled by obj_controller instance vars)
    // =========================================================================
    
    // =========================================================================
    // 2. CORE LOGIC
    // =========================================================================
    #region 2.0) Pre-zoom: record the world-coordinate under the mouse
    var _world_mx_before_zoom = cam_x + (_gui_mx / zoom_level);
    var _world_my_before_zoom = cam_y + (_gui_my / zoom_level);
    #endregion
    
    #region 2.1) Zoom Input
    if (mouse_wheel_up())   zoom_target = clamp(zoom_target + zoom_speed, zoom_min, zoom_max);
    if (mouse_wheel_down()) zoom_target = clamp(zoom_target - zoom_speed, zoom_min, zoom_max);
    #endregion

    #region 2.2) Smooth Zoom & refocus camera on mouse point
    if (abs(zoom_target - zoom_level) > 0.001) { 
        zoom_level += (zoom_target - zoom_level) * zoom_smooth;
    } else {
        zoom_level = zoom_target; 
    }
    
    cam_x = _world_mx_before_zoom - (_gui_mx / zoom_level);
    cam_y = _world_my_before_zoom - (_gui_my / zoom_level);
    #endregion

    #region 2.3) Middle-Mouse Drag for Camera Panning
    if (mouse_check_button_pressed(mb_middle)) {
        dragging_camera = true;
        drag_start_x    = _gui_mx; 
        drag_start_y    = _gui_my;
    }
    if (mouse_check_button_released(mb_middle)) {
        dragging_camera = false;
    }

    if (dragging_camera) {
        var _delta_gui_mx = _gui_mx - drag_start_x;
        var _delta_gui_my = _gui_my - drag_start_y;

        cam_x -= _delta_gui_mx / zoom_level;
        cam_y -= _delta_gui_my / zoom_level;

        drag_start_x = _gui_mx;
        drag_start_y = _gui_my;
    }
    #endregion

    #region 2.4) Apply Calculated Position and Size to Camera
    var _view_width_actual  = _rw / zoom_level;
    var _view_height_actual = _rh / zoom_level;
    
    // These functions should still work if _cam is a valid ID,
    // even if camera_exists() itself is problematic.
    camera_set_view_pos(_cam, cam_x, cam_y);
    camera_set_view_size(_cam, _view_width_actual, _view_height_actual);
    #endregion

    // =========================================================================
    // 3. CLEANUP & RETURN
    // =========================================================================
    #region Cleanup
    return;
    #endregion
}
