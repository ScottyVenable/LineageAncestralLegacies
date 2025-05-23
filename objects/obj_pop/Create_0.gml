/// obj_pop - Create Event
///
/// Purpose:
///    Initializes all instance variables for a new pop.
///
/// Metadata:
///    Summary:         Sets up basic pop structure and generates detailed attributes.
///    Usage:           Automatically called when an obj_pop instance is created.
///    Version:        1.10 - May 22, 2025 (Updated life stage assignment logic and ensured metadata reflects current date)
///    Dependencies:  PopState (enum), scr_generate_pop_details, spr_man_idle.

// =========================================================================
// 1. CORE GAMEPLAY STATE & FLAGS
// =========================================================================
#region 1.1 Basic State & Selection
state = PopState.IDLE;
selected = false;
depth = -y;
image_speed = 1;
sprite_index = spr_man_idle;
image_index = 0;
current_sprite = sprite_index;
is_mouse_hovering = false;

pop = get_entity_data(EntityType.POP_HOMINID);
if (is_undefined(pop)) {
	show_error("Failed to initialize 'pop': Entity data is invalid.", true);
}
#endregion

// =========================================================================
// 2. MOVEMENT & COMMAND RELATED
// =========================================================================
#region 2.1 Movement & Command Vars
speed = pop.base_speed;
direction = random(360);
travel_point_x = x;
travel_point_y = y;
has_arrived = true;
was_commanded = false;
order_id = 0;
is_waiting = false;
#endregion

// =========================================================================
// 3. BEHAVIOR TIMERS & VARIABLES
// =========================================================================
#region 3.1 Idle State Variables
idle_timer = 0;
idle_target_time = 0;
idle_min_sec = 2.0;
idle_max_sec = 4.0;
after_command_idle_time = 0.5;
#endregion

#region 3.2 Wander State Variables
wander_pts = 0;
wander_pts_target = 0;
min_wander_pts = 1;
max_wander_pts = 3;
wander_min_dist = 50;
wander_max_dist = 150;
#endregion

#region 3.3 Foraging State Variables
// target_bush = noone; // Commented out: Replaced by last_foraged_target_id for resumption logic
last_foraged_target_id = noone; // Stores the ID of the last bush this pop foraged from
last_foraged_slot_index = -1;   // Stores the slot index on the last_foraged_target_id
last_foraged_type_tag = "";     // Stores the type tag of the slot on the last_foraged_target_id
forage_timer = 0;
forage_rate = global.game_speed;
#endregion

#region 3.4 Interaction Variables
target_interaction_object_id = noone;
// target_object_id is a more generic variable for any targeted object (like a hut for hauling, or a point for commanded move)
// It should be initialized to 'noone' to prevent errors like the one encountered.
target_object_id = noone; 
_slot_index = -1; // Initialize to -1 (meaning no slot claimed)
_interaction_type_tag = "";
#endregion

// =========================================================================
// 4. GENERATE POP DETAILS (Name, Sex, Age, Stats, Traits etc.)
// =========================================================================
#region 4.1 Generate Details
// This script will set: pop_identifier_string, pop_name, sex, age, scale,
// stats (strength, etc.), health, hunger, thirst, energy, skills, traits.
// Pass the life_stage variable explicitly to scr_generate_pop_details
// Use the global life_stage variable
scr_generate_pop_details(global.life_stage);
// After scr_generate_pop_details, 'image_xscale' and 'image_yscale' will be set based on age.

// Debugging: Log the generated pop name
debug_log("Generated pop name: " + pop_identifier_string, "obj_pop:Create");

// Debugging: Log the value of pop_identifier_string to ensure it is set correctly
debug_log("Pop identifier string during creation: " + pop_identifier_string, "obj_pop:Create");
#endregion

// =========================================================================
// 5. INVENTORY (Initialize after details)
// =========================================================================
#region 5.1 Initialize Inventory
inventory_items = ds_list_create(); // Initialize as an empty list for item stacks
// inventory = {}; // This was for the old struct-based inventory, replaced by inventory_items list
max_inventory_capacity = pop.base_max_items_carried; // Initialize max inventory capacity
hauling_threshold = pop.base_max_items_carried; // Set hauling threshold based on pop's carrying capacity

// Initialize variables for resuming tasks, if not already present from a previous version
if (!variable_instance_exists(id, "previous_state")) {
    previous_state = undefined;
}
if (!variable_instance_exists(id, "last_foraged_target_id")) {
    last_foraged_target_id = noone;
}
if (!variable_instance_exists(id, "last_foraged_slot_index")) {
    last_foraged_slot_index = -1;
}
if (!variable_instance_exists(id, "last_foraged_type_tag")) {
    last_foraged_type_tag = "";
}

#endregion

// SECTION 6 (Pre-defined Name Colors) HAS BEEN REMOVED as the Draw event will use c_ltblue and c_fuchsia directly.

// SAFETY: Ensure global.game_speed is set before using it
if (!variable_global_exists("game_speed")) {
    // Fallback to room_get_speed(room) if not set, which is the standard
    global.game_speed = room_get_speed(room); 
}
forage_rate = global.game_speed;

// Ensure global.life_stage is initialized before proceeding
if (!variable_global_exists("life_stage")) {
    show_error("Global variable 'life_stage' is not initialized. Ensure obj_controller is created first.", true);
    exit; // Stop further execution to prevent errors
}

// Assign the PopLifeStage in the Create Event of the pop object
if (global.first_load) {
    life_stage = PopLifeStage.TRIBAL; // Set to TRIBAL for the first game load
    debug_log("Assigned life stage TRIBAL to pop on first load.", "obj_pop:Create");
} else {
    // Dynamically determine the life stage based on game state
    life_stage = scr_determine_life_stage(); // Placeholder for dynamic logic
    debug_log("Life stage dynamically determined for this pop.", "obj_pop:Create", "yellow");
}

// Post-generation debug message is intentionally disabled for production.
// Uncomment the line below for debugging purposes during development.
// debug_log($"Pop {pop_identifier_string} fully created. State: {state}", "obj_pop:Create", "blue"); // Enable for detailed pop creation debug