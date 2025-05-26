/// scr_needs_update.gml
///
/// Purpose:
///   Manages the needs of pops (e.g., hunger, thirst), updating them over time
///   and providing functions to query and modify these needs.
///
/// Metadata:
///   Summary:       Handles pop needs like hunger and thirst.
///   Usage:         Call `needs_tick_update(pop_instance)` for each pop in its Step event.
///                  Use `get_pop_need(pop_instance, need_name)` to query a need.
///   Parameters:    Varies by function (see individual function JSDocs).
///   Returns:       Varies by function.
///   Tags:          [needs][pop][simulation][gameplay]
///   Version:       1.0 - 2025-05-26
///   Dependencies:  `scr_data_helpers` (for `get_pop_state_profile_by_id` if state transitions are handled here).
///                  Pop instances are expected to have a `needs` struct (e.g., `self.needs = { hunger: 50, thirst: 50 };`).
///   Creator:       Copilot
///   Created:       2025-05-26
///   Last Modified: 2025-05-26 by Copilot

// =========================================================================
// 4. CORE LOGIC (Function Definitions)
// =========================================================================

#region 4.1 Needs Update Function: needs_tick_update()
/// @function needs_tick_update(_pop_instance)
/// @description Updates the needs of a given pop instance for one game tick.
///              Also handles state transitions based on need thresholds.
/// @param {Id.Instance} _pop_instance The pop instance to update.
function needs_tick_update(_pop_instance) {
    // =========================================================================
    // 4.1.1. VALIDATION & EARLY RETURNS
    // =========================================================================
    if (!instance_exists(_pop_instance)) {
        show_debug_message("ERROR (needs_tick_update): Invalid pop instance provided.");
        return;
    }
    if (!variable_instance_exists(_pop_instance, "needs")) {
        show_debug_message("WARNING (needs_tick_update): Pop " + string(_pop_instance.id) + " has no 'needs' struct. Initializing default.");
        // Initialize default needs if missing (consider this a safety net, should be initialized on pop creation)
        _pop_instance.needs = {
            hunger: 50, // Default hunger on a 0-100 scale (100=full, 0=starving)
            thirst: 50  // Default thirst on a 0-100 scale (100=full, 0=parched)
            // ... other needs like energy, social, etc.
        };
    }
    if (!variable_instance_exists(_pop_instance, "current_state_id")) {
        show_debug_message("WARNING (needs_tick_update): Pop " + string(_pop_instance.id) + " has no 'current_state_id'. State transitions might fail.");
        // It's assumed current_state_id and current_state_name are managed by the pop's main state machine.
    }

    // =========================================================================
    // 4.1.2. CONFIGURATION & CONSTANTS (Function-local)
    // =========================================================================
    var _hunger_decay_rate = 0.01; // Amount hunger decreases per tick
    var _thirst_decay_rate = 0.02; // Amount thirst decreases per tick
    
    var _hunger_threshold_forage = 20; // Below this, pop considers foraging
    var _thirst_threshold_drink = 25;  // Below this, pop considers drinking (if applicable state exists)

    // =========================================================================
    // 4.1.4. CORE LOGIC (Function-local) - Update Needs
    // =========================================================================
    // Update hunger
    if (variable_struct_exists(_pop_instance.needs, "hunger")) {
        _pop_instance.needs.hunger -= _hunger_decay_rate;
        if (_pop_instance.needs.hunger < 0) _pop_instance.needs.hunger = 0;
        // if (_pop_instance.needs.hunger > 100) _pop_instance.needs.hunger = 100; // Cap at max if consuming items
    }

    // Update thirst
    if (variable_struct_exists(_pop_instance.needs, "thirst")) {
        _pop_instance.needs.thirst -= _thirst_decay_rate;
        if (_pop_instance.needs.thirst < 0) _pop_instance.needs.thirst = 0;
        // if (_pop_instance.needs.thirst > 100) _pop_instance.needs.thirst = 100; // Cap at max
    }
    
    // =========================================================================
    // 4.1.4. CORE LOGIC (Function-local) - Handle State Transitions based on Needs
    // =========================================================================
    // This is a basic example. A more robust system might use a priority queue for states
    // or allow states themselves to define their entry conditions based on needs.

    // Check for hunger
    var _foraging_state_profile = get_pop_state_profile_by_id("Foraging");
    if (!is_undefined(_foraging_state_profile) && _pop_instance.current_state_id != _foraging_state_profile.id) {
        if (_pop_instance.needs.hunger <= _hunger_threshold_forage) {
            show_debug_message("Pop " + string(_pop_instance.id) + " is hungry (" + string(_pop_instance.needs.hunger) + "). Switching to Foraging.");
            _pop_instance.current_state_id = _foraging_state_profile.id;
            _pop_instance.current_state_name = _foraging_state_profile.name;
            // Potentially interrupt current action or add Foraging to a queue
            return; // Exit after a state change to allow the new state to process
        }
    }

    // Check for thirst (Example - assuming a "Drinking" state or similar)
    /*
    var _drinking_state_profile = get_pop_state_profile_by_id("Drinking"); // Assuming such a state exists
    if (!is_undefined(_drinking_state_profile) && _pop_instance.current_state_id != _drinking_state_profile.id) {
        if (_pop_instance.needs.thirst <= _thirst_threshold_drink) {
            show_debug_message("Pop " + string(_pop_instance.id) + " is thirsty (" + string(_pop_instance.needs.thirst) + "). Switching to Drinking.");
            _pop_instance.current_state_id = _drinking_state_profile.id;
            _pop_instance.current_state_name = _drinking_state_profile.name;
            return; 
        }
    }
    */

    // =========================================================================
    // 4.1.6. DEBUG/PROFILING (Function-local)
    // =========================================================================
    // Example: Periodically log needs for a specific pop for debugging
    // if (_pop_instance.id == obj_player_character.id && (current_time % 1000 == 0)) { // Assuming current_time is available
    //     show_debug_message("Player Needs - Hunger: " + string(_pop_instance.needs.hunger) + ", Thirst: " + string(_pop_instance.needs.thirst));
    // }
}
#endregion

#region 4.2 Needs Query Function: get_pop_need()
/// @function get_pop_need(_pop_instance, _need_name)
/// @description Retrieves the current value of a specific need for a pop.
/// @param {Id.Instance} _pop_instance The pop instance.
/// @param {String} _need_name The name of the need to query (e.g., "hunger", "thirst").
/// @returns {Real} The value of the need, or undefined if the need or pop is invalid.
function get_pop_need(_pop_instance, _need_name) {
    if (!instance_exists(_pop_instance) || !variable_instance_exists(_pop_instance, "needs")) {
        return undefined;
    }
    if (variable_struct_exists(_pop_instance.needs, _need_name)) {
        return _pop_instance.needs[_need_name];
    }
    show_debug_message("WARNING (get_pop_need): Need '" + _need_name + "' not found for pop " + string(_pop_instance.id));
    return undefined;
}
#endregion

#region 4.3 Needs Modification Function: modify_pop_need()
/// @function modify_pop_need(_pop_instance, _need_name, _amount)
/// @description Modifies a specific need for a pop by a given amount (can be negative).
/// @param {Id.Instance} _pop_instance The pop instance.
/// @param {String} _need_name The name of the need to modify (e.g., "hunger", "thirst").
/// @param {Real} _amount The amount to add to the need (use negative to subtract).
function modify_pop_need(_pop_instance, _need_name, _amount) {
    if (!instance_exists(_pop_instance) || !variable_instance_exists(_pop_instance, "needs")) {
        show_debug_message("ERROR (modify_pop_need): Invalid pop or needs struct for pop " + string(_pop_instance));
        return;
    }
    if (variable_struct_exists(_pop_instance.needs, _need_name)) {
        _pop_instance.needs[_need_name] += _amount;
        // Clamp values (optional, could be handled by specific game logic, e.g. eating food)
        // if (_pop_instance.needs[_need_name] < 0) _pop_instance.needs[_need_name] = 0;
        // if (_pop_instance.needs[_need_name] > 100) _pop_instance.needs[_need_name] = 100; 
    } else {
        show_debug_message("WARNING (modify_pop_need): Need '" + _need_name + "' not found for pop " + string(_pop_instance.id));
    }
}
#endregion
