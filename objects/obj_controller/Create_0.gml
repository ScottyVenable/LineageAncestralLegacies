/// obj_controller – Create Event
///
/// Purpose:
///    Initializes core game controller variables, camera, selection system,
///    UI, global game settings (like formation type & notification vars),
///    and spawns the initial set of pops.
///
/// Metadata:
///    Summary:         Master setup for game systems, UI, and initial world state.
///    Usage:           obj_controller Create Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [controller][init][global][ui][camera][spawn][formation][notification]
///    Version:         1.6 - [Current Date] (Added formation notification global variables)
///    Dependencies:  scr_item_definitions_init, obj_UIPanel_Generic, obj_pop,
///                     Formation (enum from scr_constants.gml), room_speed

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
zoom_smooth   = 0.50;
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
global.initial_pop_count = 1000;

// Formation System Globals
global.current_formation_type = Formation.GRID;
global.formation_spacing = 48;
#endregion

#region 4.2 UI Globals & Initialization
global.mouse_event_consumed_by_ui = false;

// UI Panel Instance
if (object_exists(obj_UIPanel_Generic)) {
    var _initial_panel_config = { panel_type_arg: "none", target_data_source_id_arg: noone, custom_title_arg: "" };
    var _ui_layer_name = "UILayer";
    if (!layer_exists(_ui_layer_name)) { layer_create(10000, _ui_layer_name); show_debug_message($"Dynamically created UI layer: '{_ui_layer_name}'"); }
    global.ui_panel_instance = instance_create_layer(0, 0, _ui_layer_name, obj_UIPanel_Generic, _initial_panel_config);
    if (instance_exists(global.ui_panel_instance)) { global.ui_panel_instance.visible = false; }
    else { show_debug_message("ERROR (obj_controller Create): Failed to create global.ui_panel_instance."); global.ui_panel_instance = noone; }
} else { show_debug_message("ERROR (obj_controller Create): obj_UIPanel_Generic does not exist."); global.ui_panel_instance = noone; }

// Formation Notification Globals <<<<<----- NEWLY ADDED -----<<<<<
global.formation_notification_text = "";
global.formation_notification_alpha = 0;
global.formation_notification_timer = 0;
// Times are in game steps (frames)
global.formation_notification_stay_time = 1.5 * room_speed; // e.g., 1.5 seconds at current room_speed
global.formation_notification_fade_time = 0.5 * room_speed; // e.g., 0.5 seconds at current room_speed
#endregion

// ============================================================================
// 5. INITIALIZE OTHER CONTROLLERS/SYSTEMS
// ============================================================================
// (Other controller initializations)
#endregion

// ============================================================================
// 6. SPAWN INITIAL POPS
// ============================================================================
#region 6.1 Spawn Initial Pops
var _pop_spawn_layer = "Entities";
if (object_exists(obj_pop)) {
    if (!layer_exists(_pop_spawn_layer)) { layer_create(0, _pop_spawn_layer); show_debug_message($"Dynamically created layer: '{_pop_spawn_layer}'."); }
    var _spawn_center_x = room_width / 2;
    var _spawn_center_y = room_height / 2;
    var _spawn_radius = 100;
    var _spawn_attempts_max = global.initial_pop_count * 5;
    var _spawned_count = 0;
    for (var i = 0; i < global.initial_pop_count; i++) {
        var _attempt = 0; var _spawn_x, _spawn_y; var _valid_spot_found = false;
        while (_attempt < _spawn_attempts_max && !_valid_spot_found) {
            _attempt++; var _angle = random(360); var _dist  = random(_spawn_radius);
            _spawn_x = _spawn_center_x + lengthdir_x(_dist, _angle);
            _spawn_y = _spawn_center_y + lengthdir_y(_dist, _angle);
            _spawn_x = clamp(_spawn_x, 32, room_width - 32); _spawn_y = clamp(_spawn_y, 32, room_height - 32);
            if (!place_meeting(_spawn_x, _spawn_y, obj_pop)) { _valid_spot_found = true; }
        }
        if (_valid_spot_found) {
            var _new_pop = instance_create_layer(_spawn_x, _spawn_y, _pop_spawn_layer, obj_pop);
            _spawned_count++; // show_debug_message($"Spawned pop {i+1} (ID:{_new_pop}) at ({floor(_spawn_x)},{floor(_spawn_y)})");
        } else { show_debug_message($"Warning: Could not find valid spawn for pop {i+1}.");}
    }
    show_debug_message($"Total initial pops spawned: {_spawned_count}/{global.initial_pop_count}.");
    if (is_real(view_camera[0]) && view_camera[0] >= 0) {
        var _view_w = camera_get_view_width(view_camera[0]); var _view_h = camera_get_view_height(view_camera[0]);
        cam_x = _spawn_center_x - (_view_w / 2 / zoom_level); cam_y = _spawn_center_y - (_view_h / 2 / zoom_level);
    }
} else { show_debug_message("ERROR: obj_pop does not exist. Cannot spawn initial pops."); }
#endregion

// ============================================================================
// 7. DEBUGGING & LOGGING
// ============================================================================
#region 7.1 Initial Log
show_debug_message("obj_controller initialized successfully.");
if (instance_exists(global.ui_panel_instance)) { show_debug_message($"obj_controller: global.ui_panel_instance created with ID: {global.ui_panel_instance}");}
#endregion