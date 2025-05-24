/// scr_interaction_slot_get_by_pop(_provider_object_id, _pop_id)
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
