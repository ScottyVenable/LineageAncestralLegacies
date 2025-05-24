/// @description Initializes camera properties and sets up the view.
// Inherited from obj_controller and scr_camera_controller logic.

// --- Zoom Variables ---
zoom_level    = 1.0;
zoom_target   = 1.0;
zoom_min      = 0.5; // Smallest zoom (e.g., 0.25 for 4x room view)
zoom_max      = 2.0; // Largest zoom (e.g., 2.0 for 0.5x room view)
zoom_speed    = 0.1; // How much zoom_target changes per wheel click
zoom_smooth   = 0.15; // Smoothing factor (0.01 to 1.0). Smaller is smoother.

// --- Camera Tracking Variables ---
// cam_x and cam_y will represent the TOP-LEFT of the camera view.
// Initialize for a view centered in the room.
var _initial_view_width = room_width / zoom_level;
var _initial_view_height = room_height / zoom_level;
cam_x           = (room_width / 2) - (_initial_view_width / 2);
cam_y           = (room_height / 2) - (_initial_view_height / 2);
dragging_camera = false;
drag_start_x    = 0;     // Mouse x when camera drag started (GUI coordinates)
drag_start_y    = 0;     // Mouse y when camera drag started (GUI coordinates)

// --- Active Camera Setup ---
var _active_cam = view_camera[0];
if (is_real(_active_cam) && _active_cam >= 0) {
    debug_log($"DEBUG (obj_camera_controller): Initial active camera ID {_active_cam} appears valid.", "CameraInit", "green");
    // Ensure view is enabled and visible (can also be set in Room editor)
    view_enabled = true;
    view_visible[0] = true;

    var _view_w = room_width / zoom_level; // Calculate initial width based on zoom
    var _view_h = room_height / zoom_level; // Calculate initial height based on zoom
    
    camera_set_view_pos(_active_cam, cam_x, cam_y); // Set initial top-left position
    camera_set_view_size(_active_cam, _view_w, _view_h); // Set initial size
    debug_log($"DEBUG (obj_camera_controller): Initial camera set: Pos({string(cam_x)},{string(cam_y)}), Size({string(_view_w)},{string(_view_h)})", "CameraInit", "cyan");
} else {
    debug_log($"ERROR (obj_camera_controller): Initial camera ID from view_camera[0] is invalid or 'noone' (Value: {_active_cam}). Camera setup might fail.", "CameraInit", "red");
}

// Optional: If you want obj_controller to be able to tell the camera where to look initially (e.g., after spawning pops)
// you can add these, and obj_controller can set them.
// target_center_x = room_width / 2;
// target_center_y = room_height / 2;
// re_center_on_target = false; // Set to true by obj_controller to trigger a re-center

show_debug_message("DEBUG (obj_camera_controller): Create Event executed.");