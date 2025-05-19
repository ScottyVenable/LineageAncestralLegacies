/// obj_controller – Create Event
///
/// Purpose:
///    Initializes core game controller variables, camera, selection system,
///    and the main UI panel instance. Uses alternative camera validity check.
///
/// Metadata:
///    Summary:         Set up global game state, UI, and input handling variables.
///    Usage:           obj_controller Create Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [controller][init][global][ui][camera]
///    Version:         1.2 — 2025-05-18 (Alternative camera check in Create Event)
///    Dependencies:  display_set_gui_size(), obj_UIPanel_Generic

// ============================================================================
// 1. DISPLAY & GUI SETUP
// ============================================================================
#region 1.1 GUI Render Target
// Lock GUI render target to room size (integer-scale up / letterbox on fullscreen)
display_set_gui_size(room_width, room_height);
scr_item_definitions_init()
#endregion

// ============================================================================
// 2. SELECTION & CAMERA VARIABLES INITIALIZATION
// ============================================================================
#region 2.1 Selection Variables
selected_pop  = noone; // Stores the ID of the currently selected pop (if single selection)
sel_start_x   = 0;     // For drag-box selection
sel_start_y   = 0;
is_dragging   = false; // True when dragging a selection box
#endregion

#region 2.2 Zoom Variables
zoom_level    = 1.0;   // Current, rendered zoom
zoom_target   = 1.0;   // Target zoom we ease toward
zoom_min      = 0.5;   // 50% zoom out
zoom_max      = 2.0;   // 200% zoom in
zoom_speed    = 0.1;   // Per mouse-wheel notch
zoom_smooth   = 0.20;  // Easing factor (0.01–0.3)
#endregion

#region 2.3 Camera Tracking Variables
// These are for the *target* position and state of the camera,
// which scr_camera_controller will use and apply.
cam_x           = room_width / 2;  // Initial camera position (e.g., center of room)
cam_y           = room_height / 2;
dragging_camera = false; // True if middle mouse is dragging the camera
drag_start_x    = 0;     // Mouse x when camera drag started
drag_start_y    = 0;     // Mouse y when camera drag started
#endregion

// ============================================================================
// 3. CAMERA SETUP (Initial camera configuration)
// ============================================================================
#region 3.1 Active Camera Setup
var _active_cam = view_camera[0]; // Get the default camera for view 0

// Alternative check for camera validity if camera_exists() is not available/working:
// Valid camera IDs are usually non-negative. 'noone' is -4.
if (is_real(_active_cam) && _active_cam >= 0) { // Check if _active_cam is a valid positive number or zero
    // Camera ID seems valid, you can proceed with initial setup if needed.
    // For example, if you wanted to set its initial position or size here,
    // though scr_camera_controller will handle continuous updates in the Step event.
    // camera_set_view_pos(_active_cam, cam_x, cam_y);
    // camera_set_view_size(_active_cam, room_width / zoom_level, room_height / zoom_level);
    show_debug_message($"obj_controller: Initial active camera ID {_active_cam} appears valid.");
} else {
    show_debug_message($"ERROR (obj_controller Create): Initial camera ID from view_camera[0] is invalid or 'noone' (Value: {_active_cam}). Camera setup might fail.");
    // Handle critical error if camera is essential for startup, or rely on scr_camera_controller's check in Step event.
}
#endregion

// ============================================================================
// 4. GAMEPLAY & UI GLOBALS
// ============================================================================
#region 4.1 Gameplay Globals
global.order_counter = 0; // For issuing unique command IDs
#endregion

#region 4.2 UI Globals & Initialization
// Flag to indicate if a mouse event has been consumed by a UI element this step
global.mouse_event_consumed_by_ui = false;

// Create and store a reference to the main generic UI panel.
// This panel will be configured and shown/hidden by scr_selection_controller.
// Ensure obj_UIPanel_Generic exists and "Instances_GUI" is a valid instance layer.
if (object_exists(obj_UIPanel_Generic)) { // Check if the object asset exists
    var _initial_panel_config = {
        panel_type_arg: "none", // Or some default, like "hidden" or "unconfigured"
        target_data_source_id_arg: noone,
        custom_title_arg: "" 
        // panel_background_sprite_arg: spr_default_panel_border // If you have a very generic one
    };
    global.ui_panel_instance = instance_create_layer(0, 0, "Instances_GUI", obj_UIPanel_Generic, _initial_panel_config);
    
    if (instance_exists(global.ui_panel_instance)) {
        global.ui_panel_instance.visible = false; // Start hidden
    } else {
        show_debug_message("ERROR (obj_controller Create): Failed to create global.ui_panel_instance.");
        global.ui_panel_instance = noone; // Ensure it's noone if creation failed
    }
} else {
    show_debug_message("ERROR (obj_controller Create): obj_UIPanel_Generic does not exist as an object asset.");
    global.ui_panel_instance = noone;
}
#endregion

// ============================================================================
// 5. INITIALIZE CONTROLLERS/SYSTEMS
// ============================================================================
// scr_camera_controller() is typically called in the Step Event for continuous updates.
// If you had other one-time controller initializations, they would go here.
#endregion

// ============================================================================
// 6. DEBUGGING & LOGGING (Optional)
// ============================================================================
#region 6.1 Initial Log
show_debug_message("obj_controller initialized.");
if (instance_exists(global.ui_panel_instance)) {
    show_debug_message($"obj_controller: global.ui_panel_instance created with ID: {global.ui_panel_instance}");
}
#endregion
