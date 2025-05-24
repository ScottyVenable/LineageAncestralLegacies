/// scr_interaction.gml
///
/// Purpose:
///    Provides a collection of utility functions for managing interaction slots
///    on "Slot Provider" objects (e.g., objects parented to par_slot_provider).
///    These functions handle finding free slots, claiming slots, releasing slots,
///    and getting the world position of a slot.
///
/// Metadata:
///    Summary:       Utility functions for generic interaction slot management.
///    Usage:         Call specific functions from this script as needed.
///                   e.g., var slot_idx = scr_interaction_slot_get_free(target_id);
///                          scr_interaction_slot_claim(target_id, slot_idx, pop_id);
///    Tags:          [utility][interaction][slots][core_gameplay_system]
///    Version:       1.0 - [Current Date]
///    Dependencies:  par_slot_provider (conceptually, functions expect target objects to have specific slot variables)

// ============================================================================
// FUNCTION: scr_interaction_slot_get_free
// ============================================================================
/// @function scr_interaction_slot_get_free(_provider_object_id, [_required_type_tag=""])
/// @description Finds a free interaction point associated with a provider object, optionally matching a type tag.
/// @param {Id.Instance} _provider_object_id   The instance ID of the slot provider object (e.g., obj_redBerryBush).
/// @param {String}      [_required_type_tag=""] Optional. If specified, only points with this interaction_type_tag will be considered.
/// @returns {Id.Instance|noone} The instance ID of a free obj_interaction_point, or noone if no suitable free point is found.
function scr_interaction_slot_get_free(_provider_object_id, _required_type_tag = "") {
    // Validate the provider object and its array of interaction point instance IDs
    if (!instance_exists(_provider_object_id) ||
        !variable_instance_exists(_provider_object_id, "interaction_slots_pop_ids")) {
        show_debug_message($"ERROR (GetFreeSlot): Provider object {_provider_object_id} invalid or missing 'interaction_slots_pop_ids' array.");
        return noone;
    }

    var _interaction_points_array = _provider_object_id.interaction_slots_pop_ids;

    for (var i = 0; i < array_length(_interaction_points_array); i++) {
        var _point_instance_id = _interaction_points_array[i];

        // Check if the stored ID is a valid obj_interaction_point instance
        if (instance_exists(_point_instance_id) && 
            (object_get_parent(_point_instance_id.object_index) == obj_interaction_point || _point_instance_id.object_index == obj_interaction_point)) {
            
            // Check if the point is free
            if (_point_instance_id.is_occupied_by_pop_id == noone) {
                // If a type tag is required, check it
                if (_required_type_tag != "") {
                    if (variable_instance_exists(_point_instance_id, "interaction_type_tag") &&
                        _point_instance_id.interaction_type_tag == _required_type_tag) {
                        // Tag matches and slot is free
                        return _point_instance_id.id; 
                    }
                    // Tag required but doesn't match, so continue to next point
                } else {
                    // No specific tag required, and slot is free
                    return _point_instance_id.id;
                }
            }
        } else if (_point_instance_id != noone) {
            // Log if the array contains an invalid ID that isn't 'noone'
            show_debug_message($"WARNING (GetFreeSlot): Provider {_provider_object_id} has an invalid or destroyed instance ID ({_point_instance_id}) in its interaction_slots_pop_ids array at index {i}.");
        }
    }

    // No suitable free slot found
    // show_debug_message($"INFO (GetFreeSlot): No free slots (matching tag: '{_required_type_tag}') found for provider {_provider_object_id}.");
    return noone;
}


// ============================================================================
// FUNCTION: scr_interaction_slot_claim
// ============================================================================
/// @function scr_interaction_slot_claim(_interaction_point_id, _pop_id)
/// @description Assigns a pop to a specific obj_interaction_point.
/// @param {Id.Instance} _interaction_point_id The instance ID of the obj_interaction_point to claim.
/// @param {Id.Instance} _pop_id             The instance ID of the pop claiming the slot.
/// @returns {Bool} True if the slot was successfully claimed, false otherwise.
function scr_interaction_slot_claim(_interaction_point_id, _pop_id) {
    // Validate the interaction point instance
    if (!instance_exists(_interaction_point_id) || 
        !(object_get_parent(_interaction_point_id.object_index) == obj_interaction_point || _interaction_point_id.object_index == obj_interaction_point)) {
        show_debug_message($"ERROR (ClaimSlot): Invalid interaction point ID provided: {_interaction_point_id}.");
        return false;
    }

    // Validate the pop instance
    if (!instance_exists(_pop_id)) {
        show_debug_message($"ERROR (ClaimSlot): Invalid pop ID provided: {_pop_id} for point {_interaction_point_id}.");
        return false;
    }
    
    // Check if the interaction point is already occupied by a DIFFERENT pop
    if (_interaction_point_id.is_occupied_by_pop_id != noone && _interaction_point_id.is_occupied_by_pop_id != _pop_id) {
        show_debug_message($"WARNING (ClaimSlot): Pop {_pop_id} tried to claim busy point {_interaction_point_id} (Occupied by: {_interaction_point_id.is_occupied_by_pop_id}).");
        return false; // Point was not free (occupied by someone else)
    }
    
    // Claim the point
    _interaction_point_id.is_occupied_by_pop_id = _pop_id;
    // show_debug_message($"INFO (ClaimSlot): Pop {_pop_id} claimed interaction point {_interaction_point_id}.");
    return true;
}


// ============================================================================
// FUNCTION: scr_interaction_slot_release
// ============================================================================
/// @function scr_interaction_slot_release(_interaction_point_id, _pop_id)
/// @description Releases an interaction point if it is currently occupied by the given pop.
/// @param {Id.Instance} _interaction_point_id The instance ID of the obj_interaction_point to release.
/// @param {Id.Instance} _pop_id             The instance ID of the pop releasing the slot.
/// @returns {Bool} True if the slot was successfully released, false otherwise.
function scr_interaction_slot_release(_interaction_point_id, _pop_id) {
    // Validate the interaction point instance
    if (!instance_exists(_interaction_point_id) || 
        !(object_get_parent(_interaction_point_id.object_index) == obj_interaction_point || _interaction_point_id.object_index == obj_interaction_point)) {
        show_debug_message($"ERROR (ReleaseSlot): Invalid interaction point ID provided: {_interaction_point_id}.");
        return false;
    }

    // Validate the pop instance
    if (!instance_exists(_pop_id)) {
        show_debug_message($"ERROR (ReleaseSlot): Invalid pop ID provided: {_pop_id} for point {_interaction_point_id}.");
        return false;
    }

    // Only release if the point is currently occupied by this pop
    if (_interaction_point_id.is_occupied_by_pop_id == _pop_id) {
        _interaction_point_id.is_occupied_by_pop_id = noone;
        // show_debug_message($"INFO (ReleaseSlot): Pop {_pop_id} released interaction point {_interaction_point_id}.");
        return true;
    } else {
        // show_debug_message($"WARNING (ReleaseSlot): Pop {_pop_id} tried to release point {_interaction_point_id}, but it was not occupied by this pop.");
        return false;
    }
}


// ============================================================================
// FUNCTION: scr_interaction_slot_get_world_pos
// ============================================================================
/// @function scr_interaction_slot_get_world_pos(_provider_object_id, _slot_index)
/// @description Calculates the world x,y coordinates and interaction type tag of a specific interaction slot.
///              In the new system, this retrieves the data from the obj_interaction_point instance.
/// @param {Id.Instance} _provider_object_id The instance ID of the slot provider object (e.g., obj_redBerryBush).
/// @param {Real}        _slot_index         The index of the slot on the provider.
/// @returns {Struct|Undefined} A struct { x: world_x, y: world_y, type_tag: string, point_id: Id.Instance } or undefined if invalid.
function scr_interaction_slot_get_world_pos(_provider_object_id, _slot_index) {
    // Validate the provider object and its array of interaction point instance IDs
    if (!instance_exists(_provider_object_id) ||
        !variable_instance_exists(_provider_object_id, "interaction_slots_pop_ids")) {
        show_debug_message($"ERROR (GetWorldPos): Provider object {_provider_object_id} invalid or missing 'interaction_slots_pop_ids' array.");
        return undefined;
    }

    var _interaction_points_array = _provider_object_id.interaction_slots_pop_ids;

    // Validate the slot_index
    if (_slot_index < 0 || _slot_index >= array_length(_interaction_points_array)) {
        show_debug_message($"ERROR (GetWorldPos): Slot index {_slot_index} out of bounds for provider {_provider_object_id}.");
        return undefined;
    }

    var _point_instance_id = _interaction_points_array[_slot_index];

    // Validate the interaction point instance itself
    if (!instance_exists(_point_instance_id) || !(object_get_parent(_point_instance_id.object_index) == obj_interaction_point || _point_instance_id.object_index == obj_interaction_point) ) {
        show_debug_message($"ERROR (GetWorldPos): Interaction point instance ID {_point_instance_id} (at slot {_slot_index} of provider {_provider_object_id}) is not a valid obj_interaction_point.");
        return undefined;
    }

    // Ensure the interaction point has the necessary variables
    if (!variable_instance_exists(_point_instance_id, "interaction_type_tag")) {
        show_debug_message($"ERROR (GetWorldPos): Interaction point instance {_point_instance_id} is missing 'interaction_type_tag'.");
        return undefined;
    }

    // All checks passed, return the data from the obj_interaction_point instance
    return {
        x: _point_instance_id.x,                       // World X position of the point
        y: _point_instance_id.y,                       // World Y position of the point
        type_tag: _point_instance_id.interaction_type_tag, // Interaction type tag from the point
        point_id: _point_instance_id,                  // The ID of the interaction point itself
        slot_index: _slot_index                        // Always include slot_index for robust downstream logic
    };
}


// ============================================================================
// FUNCTION: scr_interaction_slot_get_by_pop
// ============================================================================
/**
 * Returns the interaction point instance ID currently claimed by a given pop on a provider object.
 *
 * @param {Id.Instance} _provider_object_id  The instance ID of the slot provider (e.g., a bush or structure).
 * @param {Id.Instance} _pop_id              The instance ID of the pop to check for.
 * @returns {Id.Instance|noone} The interaction point instance ID claimed by the pop, or noone if not found.
 *
 * Educational Note:
 *  - This function loops through all interaction points (slots) on the provider object.
 *  - It checks if any slot's `is_occupied_by_pop_id` matches the given pop's ID.
 *  - Returns the slot's instance ID if found, or noone if the pop is not occupying any slot.
 */
function scr_interaction_slot_get_by_pop(_provider_object_id, _pop_id) {
    // Validate the provider object and its array of interaction point instance IDs
    if (!instance_exists(_provider_object_id) ||
        !variable_instance_exists(_provider_object_id, "interaction_slots_pop_ids")) {
        show_debug_message("ERROR (GetByPop): Provider object invalid or missing 'interaction_slots_pop_ids' array.");
        return noone;
    }

    var _interaction_points_array = _provider_object_id.interaction_slots_pop_ids;

    // Loop through all interaction points (slots) on the provider
    for (var i = 0; i < array_length(_interaction_points_array); i++) {
        var _point_instance_id = _interaction_points_array[i];
        if (instance_exists(_point_instance_id) &&
            (object_get_parent(_point_instance_id.object_index) == obj_interaction_point || _point_instance_id.object_index == obj_interaction_point)) {
            // Check if this slot is occupied by the given pop
            if (_point_instance_id.is_occupied_by_pop_id == _pop_id) {
                // Found the slot claimed by this pop
                return _point_instance_id;
            }
        }
    }
    // If no slot is found for this pop, return noone
    return noone;
}


// ============================================================================
// FUNCTION: scr_interaction_slot_acquire
// ============================================================================
/**
 * Attempts to acquire (claim) an available interaction slot for a pop on a provider object.
 * Optionally matches a specific slot index or type tag.
 *
 * @param {Id.Instance} _provider_object_id  The instance ID of the slot provider (e.g., a bush or structure).
 * @param {Id.Instance} _pop_id              The instance ID of the pop trying to acquire a slot.
 * @param {Real}        [_slot_index=-1]     Optional. If provided (>=0), tries to claim this specific slot index.
 * @param {String}      [_required_type_tag=""] Optional. If provided, only slots with this tag will be considered.
 * @returns {Struct|undefined} Slot details struct (see scr_interaction_slot_get_world_pos) if successful, or undefined if none available.
 *
 * Educational Note:
 *  - This function is useful for resuming or assigning pops to interaction points.
 *  - It tries to claim a specific slot if given, or finds any free slot matching the tag.
 */
function scr_interaction_slot_acquire(_provider_object_id, _pop_id, _slot_index = -1, _required_type_tag = "") {
    // If a specific slot index is provided, try to claim it first
    if (_slot_index >= 0) {
        var _slot_details = scr_interaction_slot_get_world_pos(_provider_object_id, _slot_index);
        if (_slot_details != undefined) {
            var _point_id = _slot_details.point_id;
            if (scr_interaction_slot_claim(_point_id, _pop_id)) {
                // Add slot_index to the returned struct for consistency
                _slot_details.slot_index = _slot_index;
                return _slot_details; // Successfully claimed specific slot
            }
        }
    }
    // Otherwise, find any free slot matching the tag
    var _free_point_id = scr_interaction_slot_get_free(_provider_object_id, _required_type_tag);
    if (_free_point_id != noone) {
        if (scr_interaction_slot_claim(_free_point_id, _pop_id)) {
            // Find the slot index for this point
            var _points = _provider_object_id.interaction_slots_pop_ids;
            var _found_index = -1;
            for (var i = 0; i < array_length(_points); i++) {
                if (_points[i] == _free_point_id) { _found_index = i; break; }
            }
            var _slot_details = scr_interaction_slot_get_world_pos(_provider_object_id, _found_index);
            if (_slot_details != undefined) {
                _slot_details.slot_index = _found_index; // Always include slot_index in the returned struct
            }
            return _slot_details;
        }
    }
    // No slot could be acquired
    return undefined;
}