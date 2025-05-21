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
///    Tags:            [controller][init][global][ui][camera][spawn][formation][notification][selection]
///    Version:         1.7 - 2024-05-19 // Scotty's Current Date - Consolidated selection vars, added click_start_world
///    Dependencies:  scr_item_definitions_init, obj_UIPanel_Generic, obj_pop,
///                     Formation (enum from scr_constants.gml), room_speed

// ============================================================================
// 1. DISPLAY & GUI SETUP
// ============================================================================
randomize();
#region 1.1 GUI Render Target
display_set_gui_size(room_width, room_height);
scr_item_definitions_init(); // Assuming this defines items
#endregion

#region 1.2 Create Status Bar
// Create Top Status Bar instance
var _top_bar_layer = "UILayer"; // Use the same UI layer as your panel
if (object_exists(obj_top_status_bar)) {
    if (!layer_exists(_top_bar_layer)) { // Ensure layer exists
        layer_create(10000, _top_bar_layer); 
        show_debug_message($"Dynamically created UI layer for Top Bar: '{_top_bar_layer}' at depth 10000.");
    }
    global.top_status_bar_instance = instance_create_layer(0, 0, _top_bar_layer, obj_top_status_bar);
    if (!instance_exists(global.top_status_bar_instance)) {
        show_debug_message("ERROR (obj_controller Create): Failed to create obj_top_status_bar instance.");
        global.top_status_bar_instance = noone;
    } else {
        show_debug_message($"obj_top_status_bar instance created (ID: {global.top_status_bar_instance}) on layer '{_top_bar_layer}'.");
    }
} else {
    show_debug_message("ERROR (obj_controller Create): obj_top_status_bar object asset does not exist.");
    global.top_status_bar_instance = noone;
}
#endregion

// ============================================================================
// 2. CORE INSTANCE VARIABLES (Selection, Camera, Click Tracking)
// ============================================================================
#region 2.1 Selection Variables (for GUI drag box & single selection tracking)
selected_pop        = noone; // Tracks a single primarily selected pop (optional if relying solely on list)
sel_start_x         = 0;     // GUI X where drag selection box started
sel_start_y         = 0;     // GUI Y where drag selection box started
is_dragging         = false; // True when actively dragging a selection box
click_start_world_x = 0;     // World X where a click/drag input began
click_start_world_y = 0;     // World Y where a click/drag input began
audio_play_sound(music1, 1, true)
show_debug_message($"DEBUG CREATE: click_start_world_x initialized to: {click_start_world_x}");
#endregion

#region 2.2 Zoom Variables
zoom_level    = 1.0;
zoom_target   = 1.0;
zoom_min      = 0.5;
zoom_max      = 2.0;
zoom_speed    = 0.1;
zoom_smooth   = 0.50; // Note: 0.5 is fairly fast smoothing, 0.1-0.2 is common for smoother
#endregion

#region 2.3 Camera Tracking Variables
cam_x           = room_width / 2;
cam_y           = room_height / 2;
dragging_camera = false;
drag_start_x    = 0;     // Mouse x when camera drag started
drag_start_y    = 0;     // Mouse y when camera drag started
#endregion

// ============================================================================
// 3. CAMERA SETUP (Initial camera configuration)
// ============================================================================
#region 3.1 Active Camera Setup
var _active_cam = view_camera[0];
if (is_real(_active_cam) && _active_cam >= 0) {
    show_debug_message($"obj_controller: Initial active camera ID {_active_cam} appears valid.");
    // camera_set_view_pos(_active_cam, cam_x - (camera_get_view_width(_active_cam)/2), cam_y - (camera_get_view_height(_active_cam)/2)); // Center camera
} else {
    show_debug_message($"ERROR (obj_controller Create): Initial camera ID from view_camera[0] is invalid or 'noone' (Value: {_active_cam}). Camera setup might fail.");
}
#endregion

// ============================================================================
// 4. GLOBAL GAME STATE & UI
// ============================================================================
#region 4.1 Gameplay Globals
global.order_counter        = 0;
global.initial_pop_count    = 10; // Example
global.pop_count            = global.initial_pop_count
global.selected_pops_list   = ds_list_create(); // Create the global list for selected pops ONCE here.

global.lineage_food_stock       = 100; // Example starting food
global.lineage_wood_stock       = 50;  // Example starting wood
global.lineage_stone_stock      = 30;  // Example starting stone
global.lineage_housing_capacity = 5;   // How many pops can be housed

// Pop count will be dynamic: instance_number(obj_pop)
global.game_day                 = 1;
global.game_time_display_string = "Morning"; // Or a numerical time
#endregion

#region 4.2 Formation System Globals
global.current_formation_type   = Formation.GRID; // Ensure Formation enum exists
global.formation_spacing        = 48;
// Formation Notification Globals
global.formation_notification_text  = "";
global.formation_notification_alpha = 0;
global.formation_notification_timer = 0;
global.formation_notification_stay_time = 1.5 * room_speed; 
global.formation_notification_fade_time = 0.5 * room_speed; 
#endregion

#region 4.3 UI Globals & Initialization
global.mouse_event_consumed_by_ui = false;

// UI Panel Instance
var _ui_layer_name = "UILayer"; // Ensure this layer exists or is created with appropriate depth
if (!layer_exists(_ui_layer_name)) { 
    layer_create(10000, _ui_layer_name); // Create layer if it doesn't exist (depth 10000 is high, good for UI)
    show_debug_message($"Dynamically created UI layer: '{_ui_layer_name}' at depth 10000.");
}

if (object_exists(obj_UIPanel_Generic)) {
    var _initial_panel_config = { panel_type_arg: "none", target_data_source_id_arg: noone, custom_title_arg: "" };
    global.ui_panel_instance = instance_create_layer(0, 0, _ui_layer_name, obj_UIPanel_Generic, _initial_panel_config);
    
    if (instance_exists(global.ui_panel_instance)) { 
        global.ui_panel_instance.visible = false; 
    } else { 
        show_debug_message("ERROR (obj_controller Create): Failed to create global.ui_panel_instance."); 
        global.ui_panel_instance = noone; 
    }
} else { 
    show_debug_message("ERROR (obj_controller Create): obj_UIPanel_Generic object asset does not exist."); 
    global.ui_panel_instance = noone; 
}
#endregion

// ============================================================================
// 5. SPAWN INITIAL POPS
// ============================================================================
#region 5.1 Spawn Initial Pops
var _pop_spawn_layer = "Entities"; // Ensure this layer exists or is created with appropriate depth (e.g., below UILayer)
if (!layer_exists(_pop_spawn_layer)) { 
    layer_create(0, _pop_spawn_layer); // Create layer if it doesn't exist (depth 0 is common for instances)
    show_debug_message($"Dynamically created Pop Spawn layer: '{_pop_spawn_layer}' at depth 0.");
}

if (object_exists(obj_pop)) {
    var _spawn_center_x = room_width / 2;
    var _spawn_center_y = room_height / 2;
    var _spawn_radius = 100; // Example
    var _spawn_attempts_max_per_pop = 10; // Max attempts to find a free spot for one pop
    var _spawned_count = 0;

    for (var i = 0; i < global.initial_pop_count; i++) {
        var _attempt = 0; 
        var _spawn_x, _spawn_y; 
        var _valid_spot_found = false;
        
        do {
            _attempt++;
            var _angle = random(360); 
            var _dist  = random(_spawn_radius);
            _spawn_x = _spawn_center_x + lengthdir_x(_dist, _angle);
            _spawn_y = _spawn_center_y + lengthdir_y(_dist, _angle);
            _spawn_x = clamp(_spawn_x, 32, room_width - 32); 
            _spawn_y = clamp(_spawn_y, 32, room_height - 32);
            
            if (!place_meeting(_spawn_x, _spawn_y, obj_pop)) { // Check against other obj_pop instances
                _valid_spot_found = true; 
            }
        } until (_valid_spot_found || _attempt >= _spawn_attempts_max_per_pop);
        
        if (_valid_spot_found) {
            var _new_pop_vars = { /* You can pass initial variables here if scr_generate_pop_details doesn't cover everything */ };
            var _new_pop = instance_create_layer(_spawn_x, _spawn_y, _pop_spawn_layer, obj_pop, _new_pop_vars);
            _spawned_count++;
        } else { 
            show_debug_message($"Warning: Could not find valid spawn spot for pop {i+1} after {_spawn_attempts_max_per_pop} attempts.");
        }
    }
    show_debug_message($"Total initial pops spawned: {_spawned_count}/{global.initial_pop_count}.");

    // Center camera on spawn area (optional)
    if (is_real(view_camera[0]) && view_camera[0] >= 0) {
        var _view_w = camera_get_view_width(view_camera[0]); 
        var _view_h = camera_get_view_height(view_camera[0]);
        // Adjust cam_x/y to be the top-left of the view for camera_set_view_pos
        camera_set_view_pos(view_camera[0], 
            _spawn_center_x - (_view_w / 2 / zoom_level), 
            _spawn_center_y - (_view_h / 2 / zoom_level)
        );
        // Keep your instance variables cam_x/y as the "target center" for your scr_camera_controller
        cam_x = _spawn_center_x; 
        cam_y = _spawn_center_y;
    }
} else { 
    show_debug_message("ERROR (obj_controller Create): obj_pop object asset does not exist. Cannot spawn initial pops."); 
}
#endregion

// ============================================================================
// 6. DEBUGGING & LOGGING
// ============================================================================
#region 6.1 Initial Log
show_debug_message("obj_controller initialized successfully.");
if (instance_exists(global.ui_panel_instance)) { 
    show_debug_message($"obj_controller: global.ui_panel_instance created with ID: {global.ui_panel_instance}");
}
#endregion