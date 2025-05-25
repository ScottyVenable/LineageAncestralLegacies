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
sprite_index = spr_man_idle; // Default sprite, can be overridden by entity_data
image_index = 0;
current_sprite = sprite_index;
is_mouse_hovering = false;

// Entity data placeholders - these will be populated by scr_spawn_entity
entity_type = EntityType.NONE; // The specific enum ID (e.g., EntityType.POP_HOMO_HABILIS_EARLY)
entity_data = undefined;       // The full data struct for this entity type
pop = undefined;               // This instance variable will hold entity_data for convenience, used by existing code

// REMOVED: Old hardcoded pop initialization:
// // Updated to use a specific Hominid species from global.EntityCategories
// // as EntityType.POP_HOMINID is obsolete.
// // This provides a default concrete entity type for obj_pop instances.
// // Consider making this configurable if obj_pop needs to represent different entity types at creation.
// pop = get_entity_data(global.EntityCategories.Hominids.Species.HOMO_HABILIS_EARLY);
// if (is_undefined(pop)) {
// 	show_error("Failed to initialize 'pop': Entity data is invalid.", true);
// }
#endregion

// =========================================================================
// 2. MOVEMENT & COMMAND RELATED
// =========================================================================
#region 2.1 Movement & Command Vars
// These will be properly initialized in initialize_from_data() after 'pop' is set.
speed = 1; // Default speed, will be overridden
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
target_object_id = noone;
_slot_index = -1; 
_interaction_type_tag = "";
#endregion

// =========================================================================
// 4. GENERATE POP DETAILS (Name, Sex, Age, Stats, Traits etc.)
// =========================================================================
#region 4.1 Generate Details
// This section will be effectively handled within initialize_from_data()
// after 'pop' (entity_data) is properly assigned.
// The call to scr_generate_pop_details will be moved into initialize_from_data().
#endregion

// =========================================================================
// 5. INVENTORY (Initialize after details)
// =========================================================================
#region 5.1 Initialize Inventory
inventory_items = ds_list_create();

// These will be properly initialized in initialize_from_data()
max_inventory_capacity = 10; // Default capacity, will be overridden
hauling_threshold = 10;    // Default threshold, will be overridden

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

// =========================================================================
// X. INITIALIZE FROM DATA METHOD (Called by scr_spawn_entity)
// =========================================================================
#region X.1 Initialize From Data Method
initialize_from_data = function() {
    // This function is called by scr_spawn_entity after the instance is created
    // and self.entity_type and self.entity_data have been assigned.

    // Ensure entity_data is valid (it should be, as scr_spawn_entity checks)
    if (is_undefined(self.entity_data)) {
        var _msg = $\"FATAL (obj_pop.initialize_from_data): self.entity_data is undefined for entity_type {entity_type_to_string(self.entity_type)}. This should not happen if spawned via scr_spawn_entity.\";
        show_error(_msg, true);
        return; // Stop further initialization if data is missing
    }

    // Assign the received entity_data to the instance variable 'pop'
    // This 'pop' variable is used throughout the existing obj_pop code.
    pop = self.entity_data; // 'self.pop = self.entity_data;' also works

    // --- Initialize/Re-initialize variables that depend on 'pop' (i.e., entity_data) ---

    // Sprite Initialization (from Section 1)
    if (struct_exists(pop, "default_sprite") && !is_undefined(pop.default_sprite)) {
        sprite_index = pop.default_sprite;
        current_sprite = pop.default_sprite;
    } else {
        // Fallback to the already set spr_man_idle or log a warning
        show_debug_message($\"WARNING (obj_pop.initialize_from_data): No default_sprite in entity_data for '{pop.name}'. Using current sprite: {sprite_get_name(sprite_index)}.\");
    }
    image_index = 0; // Reset animation frame

    // Movement Speed (from Section 2)
    if (struct_exists(pop, "base_speed_units_sec")) {
        speed = pop.base_speed_units_sec;
    } else {
        speed = 1; // Fallback speed if not defined in data
        show_debug_message($\"WARNING (obj_pop.initialize_from_data): No base_speed_units_sec in entity_data for '{pop.name}'. Using fallback speed: {speed}.\");
    }
    
    // Inventory Capacity (from Section 5)
    if (struct_exists(pop, "carrying_capacity_units")) {
        max_inventory_capacity = pop.carrying_capacity_units;
        hauling_threshold = pop.carrying_capacity_units; // Assuming threshold is same as max capacity
    } else {
        max_inventory_capacity = 10; // Fallback capacity
        hauling_threshold = 10;    // Fallback threshold
        show_debug_message($\"WARNING (obj_pop.initialize_from_data): No carrying_capacity_units in entity_data for '{pop.name}'. Using fallback capacity: {max_inventory_capacity}.\");
    }

    // Generate Pop Details (from Section 4)
    // This script (scr_generate_pop_details) likely uses the 'pop' struct and other instance variables.
    // It's crucial that 'pop' is correctly assigned from self.entity_data before this call.
    // Also ensure global.life_stage is available.
    if (variable_global_exists("life_stage")) {
        scr_generate_pop_details(global.life_stage);
    } else {
        // This error is critical as pop generation depends on it.
        show_error("FATAL (obj_pop.initialize_from_data): Global variable 'life_stage' is not initialized prior to calling scr_generate_pop_details. Ensure obj_controller or game setup initializes it.", true);
    }
    
    // Initialize health (example, actual health stats might be set within scr_generate_pop_details)
    // If scr_generate_pop_details sets stats like 'current_health_stat' and 'max_health_stat' based on 'pop.max_health',
    // then this explicit setting might not be needed. Verify how health is handled by that script.
    if (struct_exists(pop, "max_health")) {
        // Assuming 'health' is the variable for current health and 'max_health_stat' for max.
        // Adjust if your variables are named differently (e.g., current_hp, max_hp).
        // self.health = pop.max_health; // Set current health to max
        // self.max_health_stat = pop.max_health; // Set max health stat
        // If scr_generate_pop_details handles this, these lines might be redundant or need adjustment.
    } else {
         show_debug_message($\"WARNING (obj_pop.initialize_from_data): No max_health in entity_data for '{pop.name}'. Health may not be set correctly unless handled by scr_generate_pop_details.\");
    }

    // Log successful initialization
    var _pop_id_string = "Unknown Pop";
    if (variable_instance_exists(id, "pop_identifier_string")) {
        _pop_id_string = pop_identifier_string; // This should be set by scr_generate_pop_details
    }
    show_debug_message($\"INFO (obj_pop.initialize_from_data): Pop '{_pop_id_string}' (Entity: '{pop.name}') initialized with data for type {entity_type_to_string(self.entity_type)}.\");
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
// debug_log($\"Pop {pop_identifier_string} fully created. State: {state}\", "obj_pop:Create", "blue"); // Enable for detailed pop creation debug