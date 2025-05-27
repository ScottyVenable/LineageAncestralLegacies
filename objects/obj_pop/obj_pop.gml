// Check if an initialization method exists for the profile and call it.
// Using method_get(instance, "method_name") which returns 'undefined' if the method doesn't exist.
// This is the correct way to check for a method's existence in GML.
var _init_method = method_get(self, "initialize_from_profile");
if (!is_undefined(_init_method)) {
    // Call the method if it exists
    _init_method(self);
}

#region Core Logic - State Machine & Behavior
// Inherit the parent event
// This line ensures that any code in the parent object's Create event also runs.
// Useful if obj_pop inherits from another object with its own setup.
// event_inherited(); // Uncomment if this object has a parent with a Create event to inherit.

// Initialize Pop Variables

// Core Identification & Display
pop_name = "Unnamed Pop"; // Default name, should be overridden by spawner or generation script.
pop_id_string = "pop_" + string(id); // Unique string identifier for this pop instance.
sex = irandom_range(0, 1) == 0 ? "Male" : "Female"; // Randomly assign sex. 0 for Male, 1 for Female.
age = 0; // Age in game ticks or a defined time unit. Initialized to 0.

// State Machine
// current_state_id = PopState.Idle; // Initial state. PopState enum should define available states.
// current_state_profile_ref = get_pop_state_profile_by_id(current_state_id);
// if (is_undefined(current_state_profile_ref)) {
//     debug_message("ERROR: Pop " + string(id) + " could not find 'Idle' state profile.");
    // current_state_profile_ref = get_pop_state_profile_by_id(PopState.Idle); // Fallback, though this might also fail if Idle is missing.
// }
// state_timer = 0; // Timer for state-specific behaviors.
// state_initialized = false; // Flag to run state entry logic once.

// Movement & Position
target_x = x; // Target x-coordinate for movement.
target_y = y; // Target y-coordinate for movement.
move_speed = 1.5; // Pixels per step. Should be influenced by stats or archetype.
path = undefined; // Path asset for mp_grid_path.
path_position = 0; // Current position along the path.

// Attributes & Stats (Example structure - adapt as needed)
// stats = {
//     health: 100,
//     max_health: 100,
//     hunger: 0,
//     max_hunger: 100, // Point at which pop becomes hungry
//     energy: 100,
//     max_energy: 100
// };

// Skills (Example structure - adapt as needed)
// skills = {}; // This will be populated with PopSkill enums as keys.
// Example: skills[$ PopSkill.Foraging] = { level: 1, xp: 0, aptitude: 1.0 };

// Inventory
// inventory_items = ds_list_create(); // List to store item structs or IDs.
// max_carry_capacity = 10; // Max number of items or total weight.

// Relationships & Social
// faction_id = Faction.Player; // Allegiance.
// relationships = ds_map_create(); // Key: instance_id of other pop, Value: relationship score.

// Task & Work Related
// current_task = undefined; // Struct or ID of the current task.
// task_progress = 0;
// interaction_target_object_id = noone; // The object this pop is interacting with (e.g., a tree, crafting station)
// interaction_target_slot_index = -1;   // The specific slot index on the target object (if applicable)

// Appearance
// sprite_override = noone; // If a state or item changes the sprite temporarily.
// image_xscale = 1; // Default facing direction.
// image_yscale = 1;

// Debug & Pathfinding
show_path = false; // For debugging, draw the current path.

// Call a general initialization script for this pop
// This is where more complex setup, potentially based on archetype or other factors, can occur.
// scr_initialize_pop_instance(id); // Pass self 'id' to the script.

// Initial debug message
// debug_message("Pop instance " + pop_id_string + " created at (" + string(x) + "," + string(y) + ").");

// --- NEW STATE MACHINE INITIALIZATION ---
// Initialize state machine variables
current_state_id = PopState.Idle; // Default starting state
previous_state_id = PopState.Idle; // Initialize previous state
state_timer = 0;             // Timer for state-specific logic
state_initialized = false;   // Flag to run state entry logic only once per state change

// Get the profile for the initial state
current_state_profile_ref = get_pop_state_profile_by_id(current_state_id);

// Validate that the state profile was found
if (is_undefined(current_state_profile_ref)) {
    // Log an error if the default state profile is missing. This is a critical setup issue.
    debug_message("ERROR: Pop " + string(id) + " could not find profile for initial state: '" + string(current_state_id) + "'. Check pop_state_data.json and PopState enum.");
    // As a last resort, you might try to force a known safe state, but the underlying data issue must be fixed.
    // current_state_id = PopState.Idle; // Or some other guaranteed safe state
    // current_state_profile_ref = get_pop_state_profile_by_id(current_state_id);
    // If even this fails, the game might be in an unrecoverable state for this pop.
}

// Initialize other pop-specific variables that might depend on archetype, game conditions, etc.
// This could involve calling scr_generate_pop_details(id) or similar.
// For now, we assume basic defaults are set above or will be handled by a spawner.

debug_message($"Pop {pop_id_string} Create Event: Initialized. State: {current_state_id}. Profile loaded: {!is_undefined(current_state_profile_ref)}");

// Simple state machine based on current_state_id
switch (current_state_id) {
    case get_pop_state_profile_by_id("Idle").id: // Assumes get_pop_state_profile_by_id returns a struct with .id
        // scr_pop_idle(self); // Call idle behavior script
        // For now, just log
        if (random(100) < 1) {
            debug_message("Pop " + string(id) + " is Idle.");
        }
        break;
    case get_pop_state_profile_by_id("Foraging").id:
        // scr_pop_forage(self); // Call foraging behavior script
        if (random(100) < 1) {
            debug_message("Pop " + string(id) + " is Foraging.");
        }
        break;
    case get_pop_state_profile_by_id("Resting").id:
        // scr_pop_rest(self); // Call resting behavior script
        if (random(100) < 1) {
            debug_message("Pop " + string(id) + " is Resting.");
        }
        break;
    default:
        // Handle unknown state, possibly revert to Idle
        debug_message("WARNING: Pop " + string(id) + " in unknown state: " + string(current_state_id) + ". Reverting to Idle.");
        var _idle_state_profile_fallback = get_pop_state_profile_by_id("Idle");
        if (!is_undefined(_idle_state_profile_fallback)) {
            current_state_id = _idle_state_profile_fallback.id;
            current_state_name = _idle_state_profile_fallback.name;
        } else {
            current_state_id = 0; // Hardcoded fallback
            current_state_name = "Unknown (Default)";
        }
        break;
}

// Update needs (example - will be moved to a dedicated script)
//if (variable_instance_exists(self, "needs")) {
//    needs.hunger -= 0.01; // Decrease hunger over time
//    needs.thirst -= 0.02; // Decrease thirst over time
//
//    if (needs.hunger < 0) needs.hunger = 0;
//    if (needs.thirst < 0) needs.thirst = 0;
//
//    // Example: Transition to Foraging if hunger is low
//    if (needs.hunger < 20 && current_state_id != get_pop_state_profile_by_id("Foraging").id) {
//        var _foraging_state_profile = get_pop_state_profile_by_id("Foraging");
//        if (!is_undefined(_foraging_state_profile)) {
//            show_debug_message("Pop " + string(id) + " is hungry. Switching to Foraging.");
//            current_state_id = _foraging_state_profile.id;
//            current_state_name = _foraging_state_profile.name;
//        }
//    }
//}

// Call the dedicated needs update script
if (script_exists(asset_get_index("needs_tick_update"))) { // Check if the script asset exists
    needs_tick_update(self); // Pass the current pop instance to the update function
}

#endregion

// Step Event for obj_pop

// Inherit the parent event if one exists
// event_inherited();

// --- STATE MACHINE EXECUTION ---
// This is the core logic for managing pop behavior based on its current state.

// 1. Get the AI script associated with the current state
var _ai_script = انتخابات;
if (is_struct(current_state_profile_ref) && variable_struct_exists(current_state_profile_ref, "ai_script")) {
    _ai_script = current_state_profile_ref.ai_script;
} else {
    // Log an error if the current state profile is missing or doesn't define an AI script.
    // This indicates a problem with the pop_state_data.json or the state profile creation.
    debug_message($"ERROR: Pop {pop_id_string} (State: {current_state_id}) has no AI script defined in its profile or profile is invalid. Reverting to Idle logic if possible.");
    // Attempt to fallback to a generic Idle state script if available, or handle error.
    // This might involve trying to switch to PopState.Idle and getting its script.
    // For now, it will likely result in the pop doing nothing if _ai_script remains undefined.
}

// 2. Execute the AI script if it's valid
if (!is_undefined(_ai_script) && script_exists(_ai_script)) {
    // Call the state-specific AI script. Pass the pop's instance ID for context.
    script_execute(_ai_script, id); 
} else if (!is_undefined(_ai_script)) {
    // Log an error if the script is defined in the profile but doesn't exist in the project.
    // This usually means a script was renamed, deleted, or there's a typo in pop_state_data.json.
    debug_message($"ERROR: Pop {pop_id_string} (State: {current_state_id}) AI script '{_ai_script}' is defined but does not exist. Pop will do nothing.");
}

// 3. Increment state timer
// This timer can be used by state scripts for time-based actions or transitions.
state_timer++;

// --- UNIVERSAL POP LOGIC ---
// Add any logic here that should run every step, regardless of the pop's current state.
// For example, checking for critical needs (hunger, health), environmental effects, etc.

// Example: Basic Hunger Increase (Illustrative)
/*
if (variable_instance_exists(id, "stats") && variable_struct_exists(stats, "hunger")) {
    stats.hunger += 0.01; // Arbitrary hunger increase rate
    if (stats.hunger >= stats.max_hunger) {
        stats.hunger = stats.max_hunger;
        // Potentially trigger a state change to "Hungry" or "Foraging"
        // debug_message("Pop " + string(id) + " is hungry. Switching to Foraging.");
        // change_pop_state(id, PopState.Foraging); // Example of a state change function call
    }
}
*/

// --- DEBUG DRAWING (Optional) ---
// This section can be used to draw debug information if enabled.
// For example, drawing the pop's current path or state;
/*
if (show_path && path != undefined && path_position < path_get_number_points(path)) {
    draw_path(path, x, y, true);
    draw_text(x, y - 20, "State: " + current_state_profile_ref.name);
}
*/