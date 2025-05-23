/// scr_pop_find_foraging_target.gml
///
/// Purpose:
///   Finds the nearest valid foraging target for a given pop instance.
///   It searches for instances of a specified object type (e.g., obj_redBerryBush)
///   that are harvestable, have resources, and possess available interaction slots.
///
/// Metadata:
///   Summary:       Finds the nearest suitable foraging target for a pop.
///   Usage:         Called by pops when they need to find a resource to forage.
///                  e.g., var _target_info = scr_pop_find_foraging_target(id, "berries", obj_redBerryBush);
///   Parameters:    _pop_id : Id.Instance — The ID of the pop instance that is searching.
///                  _search_tag : String — A tag indicating the type of foraging or resource being sought (e.g., "berries", "wood"). Used for context and can be used by interaction slots.
///                  _target_object_type : Asset.GMObject — The object asset to search for (e.g., obj_redBerryBush, obj_tree_pine).
///   Returns:       Struct — { target_id: Id.Instance, distance: Real } if a suitable target is found.
///                  undefined — If no suitable target is found.
///   Tags:          [pop][ai][foraging][resource][target][utility]
///   Version:       1.1 - 2025-05-23 // Updated to full TEMPLATE_SCRIPT structure
///   Dependencies:  scr_interaction_slot_has_available (or similar logic for checking target availability),
///                  Instance variables on target: is_harvestable, resource_count.

function scr_pop_find_foraging_target(_pop_id, _search_tag, _target_object_type) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    var _scr_slot_has_available = scr_interaction_slot_has_available; // Cache the script function
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    // Ensure _pop_id is a valid instance before accessing its properties.
    if (!instance_exists(_pop_id)) {
        show_debug_message("ERROR: scr_pop_find_foraging_target() — Invalid _pop_id: " + string(_pop_id) + ". Instance does not exist.");
        return undefined; // Cannot search if the searching pop doesn't exist.
    }
    // Ensure _target_object_type is a valid object asset
    if (!object_exists(_target_object_type)) {
        show_debug_message("ERROR: scr_pop_find_foraging_target() — Invalid _target_object_type: " + object_get_name(_target_object_type) + ". Object does not exist.");
        return undefined;
    }
    // Ensure _search_tag is a string
    if (!is_string(_search_tag)) {
        show_debug_message("WARNING: scr_pop_find_foraging_target() — _search_tag is not a string. Proceeding, but this might indicate an issue.");
        // Allow proceeding, but log it.
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // No specific local constants needed for this search.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // Get the position of the searching pop. These variables will be used to calculate distances.
    var _pop_x = _pop_id.x;
    var _pop_y = _pop_id.y;

    // Initialize variables to keep track of the best target found so far.
    var _nearest_target_struct = undefined; // Will store the struct { target_id, distance }
    var _min_dist = infinity; // Start with an infinitely large distance. Any valid target will be closer.
    #endregion

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1 Main Behavior / Utility Logic
    // LEARNING POINT: The 'with' statement allows us to execute code in the context of other instances.
    // Here, we iterate through all active instances of the specified _target_object_type.
    // Inside the 'with' block, 'id' refers to the ID of the current target instance,
    // and its variables (like x, y, is_harvestable) can be accessed directly.
    
    // The _search_tag is passed for context and can be used by the interaction slot system
    // to determine if a pop with a specific task can use a slot.

    with (_target_object_type) {
        // 'id' inside this 'with' block is the instance ID of the current target object.
        var _current_target_id = id; 

        // --- Target Validation ---
        // 1. Check if the target is harvestable and has resources.
        //    We need to ensure these variables exist on the target before trying to read them.
        //    Using variable_instance_exists is a robust way to prevent errors if an object
        //    of the correct type is missing expected variables (e.g. due to an error or incomplete setup).
        if (!variable_instance_exists(_current_target_id, "is_harvestable") || !_current_target_id.is_harvestable ||
            !variable_instance_exists(_current_target_id, "resource_count") || _current_target_id.resource_count <= 0) {
            // This target is either not harvestable (e.g., already depleted or not grown) or lacks the necessary variables.
            continue; // Skip to the next instance of _target_object_type.
        }

        // 2. Check if the target has any available interaction slots suitable for the _search_tag.
        var _has_available_slot = false;
        if (script_exists(_scr_slot_has_available)) {
            // Call the script to check for available slots on this specific target, considering the search tag.
            _has_available_slot = _scr_slot_has_available(_current_target_id, _search_tag);
        } else {
            // This is an important error: the helper script to check slots is missing.
            show_debug_message("CRITICAL ERROR: scr_pop_find_foraging_target() — Script 'scr_interaction_slot_has_available' not found! Cannot check slots for target " + string(_current_target_id));
            // To prevent errors, we'll assume no slot is available if the check script is missing.
            continue; 
        }

        if (!_has_available_slot) {
            // This target has no free slots for a pop to use for this specific _search_tag.
            continue; // Skip to the next instance.
        }

        // --- Target is Valid and Has Slots: Calculate Distance ---
        // 'x' and 'y' here refer to the coordinates of the current target instance.
        // '_pop_x' and '_pop_y' refer to the coordinates of the searching pop.
        var _dist = point_distance(_pop_x, _pop_y, x, y);

        // --- Update Nearest Target ---
        // If this valid target is closer than any other valid target found so far,
        // it becomes the new nearest target.
        if (_dist < _min_dist) {
            _min_dist = _dist;
            _nearest_target_struct = {
                target_id: _current_target_id, // The ID of this target instance
                distance: _dist              // The calculated distance
            };
            // For more detailed debugging during development, you could uncomment this:
            // show_debug_message("Pop " + string(_pop_id) + " found potential target " + object_get_name(object_index) + "(" + string(_current_target_id) + ") at dist " + string(_dist) + ". Min dist now: " + string(_min_dist));
        }
    } // End of 'with (_target_object_type)' block
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return Value
    // Return the struct containing the nearest target's ID and distance, or undefined if no suitable target was found.
    if (_nearest_target_struct != undefined) {
        // show_debug_message("Pop " + string(_pop_id) + " selected target " + string(_nearest_target_struct.target_id) + " at distance " + string(_nearest_target_struct.distance));
    } else {
        // show_debug_message("Pop " + string(_pop_id) + " found no suitable '" + _search_tag + "' targets of type " + object_get_name(_target_object_type));
    }
    return _nearest_target_struct;
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // No specific debug/profiling hooks in this version.
    #endregion
}
