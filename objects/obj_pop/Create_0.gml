/// obj_pop - Create Event
///
/// Purpose:
///    Initializes all instance variables for a new pop.
///
/// Metadata:
///    Summary:         Sets up basic pop structure and generates detailed attributes.
///    Usage:           Automatically called when an obj_pop instance is created.
///    Version:        1.10 - [Current Date] (Removed pre-defined name color variables as Draw event uses c_ constants directly)
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
target_bush = noone;
forage_timer = 0;
forage_rate = global.game_speed;
#endregion

#region 3.4 Interaction Variables
target_interaction_object_id = noone;
_slot_index = -1; // Initialize to -1 (meaning no slot claimed)
_interaction_type_tag = "";
#endregion

// =========================================================================
// 4. GENERATE POP DETAILS (Name, Sex, Age, Stats, Traits etc.)
// =========================================================================
#region 4.1 Generate Details
// This script will set: pop_identifier_string, pop_name, sex, age, scale,
// stats (strength, etc.), health, hunger, thirst, energy, skills, traits.
scr_generate_pop_details();
// After scr_generate_pop_details, 'image_xscale' and 'image_yscale' will be set based on age.
#endregion

// =========================================================================
// 5. INVENTORY (Initialize after details)
// =========================================================================
#region 5.1 Initialize Inventory
inventory = {}; // Initialize as an empty struct for scr_inventory_struct_add
#endregion

// SECTION 6 (Pre-defined Name Colors) HAS BEEN REMOVED as the Draw event will use c_ltblue and c_fuchsia directly.

// SAFETY: Ensure global.game_speed is set before using it
if (!variable_global_exists("game_speed")) {
    // Fallback to room_get_speed(room) if not set, which is the standard
    global.game_speed = room_get_speed(room); 
}
forage_rate = global.game_speed;

// Post-generation debug message is intentionally disabled for production.
// Uncomment the line below for debugging purposes during development.
// debug_log($"Pop {pop_identifier_string} fully created. State: {state}", "obj_pop:Create", "blue"); // Enable for detailed pop creation debug