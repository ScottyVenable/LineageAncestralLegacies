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
//event_inherited(); // Assuming a base object if applicable, otherwise remove

// Initialize state if not already set
if (!variable_instance_exists(self, "current_state_id")) {
    // Default to "Idle" state from global.GameData if available
    var _idle_state_profile = get_pop_state_profile_by_id("Idle");
    if (!is_undefined(_idle_state_profile)) {
        current_state_id = _idle_state_profile.id; // Store the numeric ID
        current_state_name = _idle_state_profile.name; // Store the string name for debugging
    } else {
        // Fallback if "Idle" state is not found (should not happen with proper data loading)
        current_state_id = 0; // Or some default enum value like PopState.IDLE
        current_state_name = "Unknown (Default)";
        show_debug_message("ERROR: Pop " + string(id) + " could not find 'Idle' state profile.");
    }
    
    // Initialize needs if not present (example)
    if (!variable_instance_exists(self, "needs")) {
        needs = {
            hunger: 50, // Example: 0-100 scale
            thirst: 50  // Example: 0-100 scale
        };
    }
}

// Simple state machine based on current_state_id
switch (current_state_id) {
    case get_pop_state_profile_by_id("Idle").id: // Assumes get_pop_state_profile_by_id returns a struct with .id
        // scr_pop_idle(self); // Call idle behavior script
        // For now, just log
        if (random(100) < 1) {
            show_debug_message("Pop " + string(id) + " is Idle.");
        }
        break;
    case get_pop_state_profile_by_id("Foraging").id:
        // scr_pop_forage(self); // Call foraging behavior script
        if (random(100) < 1) {
            show_debug_message("Pop " + string(id) + " is Foraging.");
        }
        break;
    case get_pop_state_profile_by_id("Resting").id:
        // scr_pop_rest(self); // Call resting behavior script
        if (random(100) < 1) {
            show_debug_message("Pop " + string(id) + " is Resting.");
        }
        break;
    default:
        // Handle unknown state, possibly revert to Idle
        show_debug_message("WARNING: Pop " + string(id) + " in unknown state: " + string(current_state_id) + ". Reverting to Idle.");
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