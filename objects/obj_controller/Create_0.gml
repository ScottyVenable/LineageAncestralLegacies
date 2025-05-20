/// obj_controller – Create Event
///
/// Purpose:
///    Initializes core game controller variables, camera, selection system,
///    UI, and spawns the initial set of pops on the "Entities" layer.
///
/// Metadata:
///    Version:         1.4 — [Current Date] (Spawns pops on "Entities" layer)
///    Dependencies:  ... obj_pop, scr_generate_pop_details ...

// ============================================================================
// 1. DISPLAY & GUI SETUP
// ============================================================================
#region 1.1 GUI Render Target
display_set_gui_size(room_width, room_height);
scr_item_definitions_init();
#endregion

// ============================================================================
// 2. SELECTION & CAMERA VARIABLES INITIALIZATION
// ============================================================================
#region 2.1 Selection Variables
selected_pop  = noone;
sel_start_x   = 0;
sel_start_y   = 0;
is_dragging   = false;
#endregion

#region 2.2 Zoom Variables
zoom_level    = 1.0;
zoom_target   = 1.0;
zoom_min      = 0.5;
zoom_max      = 2.0;
zoom_speed    = 0.1;
zoom_smooth   = 0.20;
#endregion

#region 2.3 Camera Tracking Variables
cam_x           = room_width / 2;
cam_y           = room_height / 2;
dragging_camera = false;
drag_start_x    = 0;
drag_start_y    = 0;
#endregion

// ============================================================================
// 3. CAMERA SETUP (Initial camera configuration)
// ============================================================================
#region 3.1 Active Camera Setup
var _active_cam = view_camera[0];
if (is_real(_active_cam) && _active_cam >= 0) {
    show_debug_message($"obj_controller: Initial active camera ID {_active_cam} appears valid.");
} else {
    show_debug_message($"ERROR (obj_controller Create): Initial camera ID from view_camera[0] is invalid or 'noone' (Value: {_active_cam}). Camera setup might fail.");
}
#endregion

// ============================================================================
// 4. GAMEPLAY & UI GLOBALS
// ============================================================================
#region 4.1 Gameplay Globals
global.order_counter = 0;
global.initial_pop_count = 5; // Define starting pop count here
#endregion

#region 4.2 UI Globals & Initialization
global.mouse_event_consumed_by_ui = false;
if (object_exists(obj_UIPanel_Generic)) {
    var _initial_panel_config = {
        panel_type_arg: "none",
        target_data_source_id_arg: noone,
        custom_title_arg: ""
    };
    // Ensure your chosen UI layer exists (e.g., "UILayer" or "Instances_GUI")
    var _ui_layer_name = "UILayer"; // Or "Instances_GUI" if that's what you use
    if (!layer_exists(_ui_layer_name)) { layer_create(100, _ui_layer_name); } // Create if not exists (adjust depth)
        
    global.ui_panel_instance = instance_create_layer(0, 0, _ui_layer_name, obj_UIPanel_Generic, _initial_panel_config);
    
    if (instance_exists(global.ui_panel_instance)) {
        global.ui_panel_instance.visible = false;
    } else {
        show_debug_message("ERROR (obj_controller Create): Failed to create global.ui_panel_instance.");
        global.ui_panel_instance = noone;
    }
} else {
    show_debug_message("ERROR (obj_controller Create): obj_UIPanel_Generic does not exist as an object asset.");
    global.ui_panel_instance = noone;
}
#endregion

// ============================================================================
// 5. INITIALIZE CONTROLLERS/SYSTEMS
// ============================================================================
// (Other controller initializations)
#endregion


// ============================================================================
// 6. SPAWN INITIAL POPS
// ============================================================================
#region 6.1 Spawn Initial Pops
var _pop_spawn_layer = "Entities"; // <<<<<----- SET SPAWN LAYER NAME HERE -----<<<<<

if (object_exists(obj_pop)) {
    // Ensure the target spawn layer exists, create it if not.
    // You might want a specific depth for "Entities" layer (e.g., 0 or 10).
    // If it's your main gameplay layer, depth 0 is common.
    if (!layer_exists(_pop_spawn_layer)) {
        layer_create(0, _pop_spawn_layer); 
        show_debug_message($"Dynamically created layer: '{_pop_spawn_layer}' for pop spawning.");
    }

    var _spawn_center_x = room_width / 2;
    var _spawn_center_y = room_height / 2;
    var _spawn_radius = 100; 
    var _spawn_attempts_max = global.initial_pop_count * 5; // Increased attempts slightly
    var _spawned_count = 0;

    for (var i = 0; i < global.initial_pop_count; i++) {
        var _attempt = 0;
        var _spawn_x, _spawn_y;
        var _valid_spot_found = false;

        while (_attempt < _spawn_attempts_max && !_valid_spot_found) {
            _attempt++;
            var _angle = random(360);
            var _dist  = random(_spawn_radius);
            
            _spawn_x = _spawn_center_x + lengthdir_x(_dist, _angle);
            _spawn_y = _spawn_center_y + lengthdir_y(_dist, _angle);

            _spawn_x = clamp(_spawn_x, 32, room_width - 32);
            _spawn_y = clamp(_spawn_y, 32, room_height - 32);

            // Check if the chosen spot is free from other pops
            if (!place_meeting(_spawn_x, _spawn_y, obj_pop)) {
                 _valid_spot_found = true;
            }
        }

        if (_valid_spot_found) {
            var _new_pop = instance_create_layer(_spawn_x, _spawn_y, _pop_spawn_layer, obj_pop);
            _spawned_count++;
            show_debug_message($"Spawned initial pop {_spawned_count}/{global.initial_pop_count} (ID: {_new_pop}) at ({floor(_spawn_x)}, {floor(_spawn_y)}) on layer '{_pop_spawn_layer}'");
        } else {
            show_debug_message($"Warning: Could not find a valid spawn location for initial pop {i + 1} after {_spawn_attempts_max} attempts near ({_spawn_center_x},{_spawn_center_y}).");
        }
    }
    show_debug_message($"Total initial pops spawned: {_spawned_count} out of {global.initial_pop_count} requested.");

    // Optionally, pan camera to the spawn location
    // Ensure camera is valid before trying to get/set view properties
    if (is_real(view_camera[0]) && view_camera[0] >= 0) {
        cam_x = _spawn_center_x - (camera_get_view_width(view_camera[0]) / 2);
        cam_y = _spawn_center_y - (camera_get_view_height(view_camera[0]) / 2);
    }

} else {
    show_debug_message("ERROR (obj_controller Create): obj_pop object asset does not exist. Cannot spawn initial pops.");
}
#endregion


// ============================================================================
// 7. DEBUGGING & LOGGING
// ============================================================================
#region 7.1 Initial Log
show_debug_message("obj_controller initialized.");
if (instance_exists(global.ui_panel_instance)) {
    show_debug_message($"obj_controller: global.ui_panel_instance created with ID: {global.ui_panel_instance}");
}
#endregion