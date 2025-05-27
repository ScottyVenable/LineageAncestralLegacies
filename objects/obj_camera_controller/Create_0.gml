/// @description Initializes camera properties and sets up the view.
// Inherited from obj_controller and scr_camera_controller logic.

// --- Zoom Variables ---
zoom_level    = 1.0;
zoom_target   = 1.0;
zoom_min      = 0.5; // Smallest zoom (e.g., 0.25 for 4x room view)
zoom_max      = 2.0; // Largest zoom (e.g., 2.0 for 0.5x room view)
zoom_speed    = 0.1; // How much zoom_target changes per wheel click
zoom_smooth   = 0.15; // Smoothing factor (0.01 to 1.0). Smaller is smoother.

// --- Camera Tracking Variables & Initial View Setup ---
var _active_cam = view_camera[0]; // Get the camera ID first
var _view_w, _view_h; // Declare here for scope across if/else

// Attempt to initialize from Room Editor settings for view_camera[0]
// This replaces the old logic of centering in the full room or using full room dimensions.
// Corrected: Use view_get_enabled() and view_get_visible() for view 0.
if (view_enabled && view_get_visible(0) && is_real(_active_cam) && _active_cam >= 0) {
    // Fetch the initial position and size from the active camera (set in Room Editor)
    cam_x = camera_get_view_x(_active_cam);
    cam_y = camera_get_view_y(_active_cam);
    _view_w = camera_get_view_width(_active_cam);
    _view_h = camera_get_view_height(_active_cam);
    debug_log($"DEBUG (obj_camera_controller): Initialized from Room Editor View: Pos({string(cam_x)},{string(cam_y)}), Size({string(_view_w)},{string(_view_h)})", "CameraInit", "green");
} else {
    // Fallback: If camera from room editor is not properly set up, or view 0 is not enabled/visible.
    // Use a default centered view with a common resolution.
    var _fallback_id_for_log = is_real(_active_cam) ? string(_active_cam) : "invalid_or_noone";
    debug_log($"WARNING (obj_camera_controller): view_camera[0] (ID: {_fallback_id_for_log}) not properly configured in Room Editor, or view 0 disabled/invisible. Using default centered view (1366x768).", "CameraInit", "orange");
    
    _view_w = 4; 
    _view_h = 768;  
    
    cam_x = (room_width / 2) - (_view_w / 2);
    cam_y = (room_height / 2) - (_view_h / 2);
    // Ensure cam_x and cam_y are within room bounds if room is smaller than default view
    // Corrected: Ensure _view_w and _view_h are positive before clamp
    cam_x = clamp(cam_x, 0, max(0, room_width - max(1, _view_w)));
    cam_y = clamp(cam_y, 0, max(0, room_height - max(1, _view_h)));
}

dragging_camera = false;
drag_start_x    = 0;     // Mouse x when camera drag started (GUI coordinates)
drag_start_y    = 0;     // Mouse y when camera drag started (GUI coordinates)

// --- Active Camera Re-affirmation & Controller State ---
// This section uses _active_cam defined earlier.
// It applies the determined cam_x, cam_y, _view_w, _view_h to the camera
// and sets the controller's own operational flags (view_enabled, view_visible[0]).
if (is_real(_active_cam) && _active_cam >= 0) {
    // Controller's own flags to enable its operation
    view_enabled = true;    // This instance variable allows the camera controller to operate.
    view_visible[0] = true; // This instance variable (related to built-in) indicates the controller considers view 0 active for its purposes.

    // Set/Re-affirm the actual camera properties
    camera_set_view_pos(_active_cam, cam_x, cam_y);
    camera_set_view_size(_active_cam, _view_w, _view_h); // Use the _view_w, _view_h determined above
    // Corrected: Use view_set_visibility for view 0, not camera_set_view_visibility with camera ID.
    // camera_set_view_visibility(_active_cam, true); // Ensure this camera renders to its viewport - This was incorrect for enabling the view itself.
    view_set_visible(0, true); // This ensures view 0 is actually visible.

    debug_log($"DEBUG (obj_camera_controller): Camera settings re-affirmed: Pos({string(cam_x)},{string(cam_y)}), Size({string(_view_w)},{string(_view_h)}). Controller enabled.", "CameraInit", "cyan");
} else {
    // If _active_cam itself is invalid (e.g., noone / -4), the controller cannot function with it.
    var _fallback_id_for_log = is_real(_active_cam) ? string(_active_cam) : "invalid_or_noone";
    debug_log($"ERROR (obj_camera_controller): Initial camera ID from view_camera[0] is invalid (Value: {_fallback_id_for_log}). Camera setup failed. Controller will be disabled.", "CameraInit", "red");
    view_enabled = false; // Disable controller operation
    // view_visible[0] = false; // Optional: also set instance's view_visible flag
}

// Optional: If you want obj_controller to be able to tell the camera where to look initially (e.g., after spawning pops)
// you can add these, and obj_controller can set them.
// target_center_x = room_width / 2;
// target_center_y = room_height / 2;
// re_center_on_target = false; // Set to true by obj_controller to trigger a re-center

// Ensure this object persists across rooms if it's meant to be a global camera controller
// persistence = true; // Uncomment if persistence is desired

// Initial debug message to confirm creation
debug_message("DEBUG (obj_camera_controller): Create Event executed.");