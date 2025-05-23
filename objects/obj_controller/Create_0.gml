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
///    Version:         1.8 - 2024-05-19 // Scotty's Current Date - Added overlay toggle logic
///    Dependencies:  scr_item_definitions_init, obj_UIPanel_Generic, obj_pop,
///                     Formation (enum from scr_constants.gml), room_speed

// ============================================================================
// 0. GLOBAL VARIABLES INITIALIZATION (Ensure before any pops are created)
// ============================================================================
#region 0.1 Initialize Global Variables
// Ensure the first_load variable is initialized
if (!variable_global_exists("first_load")) {
    global.first_load = true; // Assume it's a new game if not set
}

// Initialize global life_stage variable
if (!variable_global_exists("life_stage")) {
    if (global.first_load) {
        global.life_stage = PopLifeStage.TRIBAL; // Set to TRIBAL for the first game load
        debug_log("Global life_stage set to TRIBAL on first load.", "obj_controller:Create", "green");
    } else {
        global.life_stage = undefined; // Placeholder for dynamic assignment later
        debug_log("Global life_stage will be determined dynamically.", "obj_controller:Create", "yellow");
    }
}

// Initialize hover detection distance for pops
if (!variable_global_exists("hover_detection_distance")) {
    global.hover_detection_distance = 50; // Default hover detection distance in pixels
}
#endregion

// ============================================================================
// 1. DISPLAY & GUI SETUP
// ============================================================================
randomize();
#region 1.1 GUI Render Target
display_set_gui_size(room_width, room_height);
scr_item_definitions_init(); // Assuming this defines items
#endregion

// ============================================================================
// 2. CORE INSTANCE VARIABLES (Selection, Camera, Click Tracking)
// ============================================================================
#region 2.1 Selection Variables (for GUI drag box & single selection tracking)
global.selected_pop   = noone; // Tracks a single primarily selected pop (optional if relying solely on list) // MODIFIED: Made global
sel_start_x         = 0;     // GUI X where drag selection box started
sel_start_y         = 0;     // GUI Y where drag selection box started
is_dragging         = false; // True when actively dragging a selection box
click_start_world_x = 0;     // World X where a click/drag input began
click_start_world_y = 0;     // World Y where a click/drag input began

debug_log($"click_start_world_x initialized to: {click_start_world_x}", "obj_controller:Create", "cyan");
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
    debug_log($"Initial active camera ID {_active_cam} appears valid.", "obj_controller:Create", "green");
    // camera_set_view_pos(_active_cam, cam_x - (camera_get_view_width(_active_cam)/2), cam_y - (camera_get_view_height(_active_cam)/2)); // Center camera
} else {
    debug_log($"ERROR (Initial camera ID from view_camera[0] is invalid or 'noone' (Value: {_active_cam})). Camera setup might fail.", "obj_controller:Create", "red");
}
#endregion

// ============================================================================
// 4. GLOBAL GAME STATE & UI
// ============================================================================
#region 4.1 Gameplay Globals
global.musicplaying			= false
global.order_counter        = 0;
global.initial_pop_count    = 5; // Example
global.pop_count            = global.initial_pop_count
global.selected_pops_list   = ds_list_create(); // Create the global list for selected pops ONCE here.
// Initialize game_speed using the game's configured FPS (steps per second)
// This is a reliable way to handle game speed for time-based calculations.
global.game_speed			= game_get_speed(gamespeed_fps); 

global.lineage_food_stock       = 100; // Example starting food
global.lineage_wood_stock       = 50;  // Example starting wood
global.lineage_stone_stock      = 30;  // Example starting stone
global.lineage_metal_stock		= 0
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
global.formation_notification_stay_time = 1.5 * global.game_speed; 
global.formation_notification_fade_time = 0.5 * global.game_speed; 
#endregion

#region 4.3 UI Globals & Initialization
global.mouse_event_consumed_by_ui = false;
global.show_overlays = false; // Initialize overlay toggle state
global.logged_missing_selection_script = false; // Initialize flag for missing selection script log

// NOTE: The logic for finding the inspector panel has been moved to Region 5.3
// after the UI layer ID is obtained. The old logic for 
// global.inspector_panel_instance (referring to obj_window_bone) is removed from here.

#endregion

// ============================================================================
// 4.B PRE-SPAWN DATA INITIALIZATION (e.g. Name data for pops)
// ============================================================================
#region 4.B.1 Load Name Data
// Ensure name data is loaded before any pops are created, as scr_generate_pop_details needs it.
if (script_exists(scr_load_name_data)) {
    scr_load_name_data();
    debug_log("Name data loaded via scr_load_name_data().", "obj_controller:Create", "green");
} else {
    debug_log("ERROR: scr_load_name_data() script not found. Pop names may not generate correctly.", "obj_controller:Create", "red");
}
#endregion

// ============================================================================
// 4.C GLOBAL VARIABLES INITIALIZATION
// ============================================================================
#region 4.C.1 Initialize Global Variables
// Ensure the first_load variable is initialized
if (!variable_global_exists("first_load")) {
    global.first_load = true; // Assume it's a new game if not set
}

// Initialize global life_stage variable
if (!variable_global_exists("life_stage")) {
    if (global.first_load) {
        global.life_stage = PopLifeStage.TRIBAL; // Set to TRIBAL for the first game load
        debug_log("Global life_stage set to TRIBAL on first load.", "obj_controller:Create", "green");
    } else {
        global.life_stage = undefined; // Placeholder for dynamic assignment later
        debug_log("Global life_stage will be determined dynamically.", "obj_controller:Create", "yellow");
    }
}
#endregion

// ============================================================================
// 5. SET THE GAME START
// ============================================================================
#region 5.1 Spawn Initial Pops
var _pop_spawn_layer = "Entities"; // Ensure this layer exists or is created with appropriate depth (e.g., below UILayer)
if (!layer_exists(_pop_spawn_layer)) { 
    layer_create(0, _pop_spawn_layer); // Create layer if it doesn't exist (depth 0 is common for instances)
    debug_log($"Dynamically created Pop Spawn layer: '{_pop_spawn_layer}' at depth 0.", "obj_controller:Create", "cyan");
}

if (object_exists(obj_pop)) {
    // SAFETY CHECK: Ensure pop entity data is valid before spawning pops
    var _pop_entity_data = get_entity_data(EntityType.POP_HOMINID);
    if (_pop_entity_data == undefined) {
        show_error("ERROR: EntityType.POP_HOMINID is not defined in the entity database. Cannot spawn pops!", true);
        // Optionally: exit or return to prevent further errors
    }
    
    var _spawn_center_x = room_width / 2;
    var _spawn_center_y = room_height / 2;
    var _spawn_radius = 250; // Example
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
            debug_log($"Warning: Could not find valid spawn spot for pop {i+1} after {_spawn_attempts_max_per_pop} attempts.", "obj_controller:Create", "yellow");
        }
    }
    debug_log($"Total initial pops spawned: {_spawned_count}/{global.initial_pop_count}.", "obj_controller:Create", "green");

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
    debug_log("ERROR (obj_pop object asset does not exist. Cannot spawn initial pops.)", "obj_controller:Create", "red");
}
#endregion

#region 5.2 Initialize & Play Sounds/Music
if (global.musicplaying == true){
	audio_play_sound(music1, 1, true)
}
#endregion

#region 5.3 Set UI Text Elements & Inspector Panel Visibility
// Get the ID of the layer where UI elements are placed.
// This is crucial for finding both text elements and the Inspector Flex Panel.
text_layer_id = layer_get_id("UI"); 

if (text_layer_id == -1) {
    // Log an error if the UI layer isn't found, as UI functionality will be broken.
    debug_log("ERROR: UI layer named 'UI' not found! Inspector Panel and text elements cannot be initialized.", "obj_controller:Create:UI", "red");
} else {
    // --- Initialize Inspector Panel Element ---
    // This is the Flex Panel that contains all inspector content.
    // We will find it by its name on the UI layer.
    global.inspector_panel_element_id = noone; // Use 'noone' or another suitable indicator for "not found"

    // Attempt to get the element ID of the Inspector Flex Panel by its name.
    // LEARNING POINT: layer_get_element_by_name is useful for accessing named UI elements
    // placed in the Room Editor directly on a layer.
    var _panel_id = layer_get_element_by_name(text_layer_id, "FlexPanel_Inspector");

    // Validate the retrieved panel ID.
    // layer_get_element_by_name returns undefined if not found, or an ID.
    // We also check if the element type is valid.
    if (_panel_id != undefined && layer_get_element_type(_panel_id) != layerelementtype_undefined) {
        global.inspector_panel_element_id = _panel_id;
        // Initially hide the entire Inspector Flex Panel.
        // scr_selection_controller will make it visible when a single pop is selected.
        layer_element_visible(global.inspector_panel_element_id, false);
        debug_log("Found Inspector Flex Panel element (ID: " + string(global.inspector_panel_element_id) + ") by name 'FlexPanel_Inspector' on UI layer. Initial visibility set to false.", "obj_controller:Create:UI", "green");
    } else {
        // Log a warning if the panel isn't found. This is critical for debugging UI setup.
        debug_log("WARNING: Inspector Flex Panel element named 'FlexPanel_Inspector' NOT FOUND on the 'UI' layer. Panel visibility cannot be managed. " +
                  "To fix: Ensure a Panel element (likely a Flex Panel) with the exact name 'FlexPanel_Inspector' exists on the 'UI' layer in your Room Editor.", "obj_controller:Create:UI", "red");
    }

    // --- Initialize UI Text Elements (existing logic) ---
    // This struct will store references to individual text elements for quick updates.
    global.ui_text_elements = {}; 

    var elements_on_layer = layer_get_all_elements(text_layer_id);
    for (var i = 0; i < array_length(elements_on_layer); i++) {
        var element_id = elements_on_layer[i];
        if (layer_get_element_type(element_id) == layerelementtype_text) {
            var initial_text = layer_text_get_text(element_id);
            debug_log($"Found text element {element_id} with text: '{initial_text}'", "obj_controller:Create:UI", "cyan");

            // Example: Identify by a unique placeholder text you put in the room editor
            if (string_pos("F0", initial_text) > 0) { // If its initial text was "FOOD_COUNT_PLACEHOLDER"
                global.ui_text_elements.food = element_id;
                debug_log($"Assigned food text element: {element_id}", "obj_controller:Create:UI", "green");
				layer_text_text(global.ui_text_elements.food, global.lineage_food_stock)
            } else if (string_pos("W1", initial_text) > 0) {
                global.ui_text_elements.wood = element_id;
				debug_log($"Assigned wood text element: {element_id}", "obj_controller:Create:UI", "green");
				layer_text_text(global.ui_text_elements.wood, global.lineage_wood_stock)
            } else if (string_pos("S2", initial_text) > 0) {
                global.ui_text_elements.stone = element_id;
				debug_log($"Assigned stone text element: {element_id}", "obj_controller:Create:UI", "green");
				layer_text_text(global.ui_text_elements.stone, global.lineage_stone_stock)
            } else if (string_pos("M3", initial_text) > 0) {
                global.ui_text_elements.metal = element_id;
				debug_log($"Assigned metal text element: {element_id}", "obj_controller:Create:UI", "green");
				layer_text_text(global.ui_text_elements.metal, global.lineage_metal_stock)
            }
            // --- Pop Inspector Panel Elements ---
            // Ensure your text elements in the Room Editor for the Pop Details panel
            // have these exact placeholder strings as their initial text.
            else if (string_pos("POP_NAME_PLACEHOLDER", initial_text) > 0) {
                global.ui_text_elements.pop_name_display = element_id;
                debug_log($"Assigned Pop Name Display text element: {element_id}", "obj_controller:Create:UI", "green");
                layer_text_text(global.ui_text_elements.pop_name_display, "N/A"); // Default to N/A
            } else if (string_pos("POP_SEX_PLACEHOLDER", initial_text) > 0) {
                global.ui_text_elements.pop_sex_display = element_id;
                debug_log($"Assigned Pop Sex Display text element: {element_id}", "obj_controller:Create:UI", "green");
                layer_text_text(global.ui_text_elements.pop_sex_display, "N/A"); // Default to N/A
            } else if (string_pos("POP_AGE_PLACEHOLDER", initial_text) > 0) {
                global.ui_text_elements.pop_age_display = element_id;
                debug_log($"Assigned Pop Age Display text element: {element_id}", "obj_controller:Create:UI", "green");
                layer_text_text(global.ui_text_elements.pop_age_display, "N/A"); // Default to N/A
            }
        }
    }
}
#endregion
// ============================================================================
// 6. DEBUGGING & LOGGING
// ============================================================================
#region 6.1 Initial Log
// Moved to the end for better organization
if (!variable_global_exists("first_load")) {
    global.first_load = true; // Assume it's a new game if not set
}

if (global.first_load) {
    debug_log("First load detected. Setting initial pop life stage to TRIBAL.", "obj_controller:Create", "green");
    global.pop_life_stage = PopLifeStage.TRIBAL; // Set the initial life stage for pops
} else {
    debug_log("Not the first load. Pop life stage will be determined dynamically.", "obj_controller:Create", "yellow");
}

if (!variable_global_exists("life_stage")) {
    if (global.first_load) {
        global.life_stage = PopLifeStage.TRIBAL; // Set to TRIBAL for the first game load
        debug_log("Global life_stage set to TRIBAL on first load.", "obj_controller:Create", "green");
    } else {
        global.life_stage = undefined; // Placeholder for dynamic assignment later
        debug_log("Global life_stage will be determined dynamically.", "obj_controller:Create", "yellow");
    }
}

// Log initialization success
debug_log("obj_controller initialized successfully.", "obj_controller:Create", "blue");
debug_log($"Music playing set to: {global.musicplaying}", "obj_controller:Create", "blue");
#endregion

// Initialize global name data variables
if (!variable_global_exists("male_prefixes")) {
    global.male_prefixes = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_male_prefixes.txt");
}
if (!variable_global_exists("male_suffixes")) {
    global.male_suffixes = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_male_suffixes.txt");
}
if (!variable_global_exists("female_prefixes")) {
    global.female_prefixes = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_female_prefixes.txt");
}
if (!variable_global_exists("female_suffixes")) {
    global.female_suffixes = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_female_suffixes.txt");
}

// Initialize the variable to track the last known selected pop for UI updates.
// This is used in the Step event (region 4.1) to optimize UI refresh calls.
_last_known_selected_pop = noone;

// Initialize the flag for logging missing selection script errors.
// This prevents spamming the console if the script is not found.
global.logged_missing_selection_script = false;
