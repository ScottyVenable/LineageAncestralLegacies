/// scr_interaction_slot_has_available(_provider_object_id, _required_type_tag)
/**
 * Checks if a provider object has at least one available (unclaimed) interaction slot, optionally matching a type tag.
 *
 * @param {Id.Instance} _provider_object_id  The instance ID of the slot provider (e.g., a bush or structure).
 * @param {String}      [_required_type_tag=""] Optional. If provided, only slots with this tag will be considered.
 * @returns {Bool} True if at least one slot is available, false otherwise.
 *
 * Educational Note:
 *  - This is useful for AI or UI logic to quickly check if a pop can interact with a target.
 *  - It loops through all slots and returns true as soon as a free one is found.
 */
function scr_interaction_slot_has_available(_provider_object_id, _required_type_tag = "") {
    if (!instance_exists(_provider_object_id) ||
        !variable_instance_exists(_provider_object_id, "interaction_slots_pop_ids")) {
        return false;
    }
    var _interaction_points_array = _provider_object_id.interaction_slots_pop_ids;
    for (var i = 0; i < array_length(_interaction_points_array); i++) {
        var _point_instance_id = _interaction_points_array[i];
        if (instance_exists(_point_instance_id) &&
            (object_get_parent(_point_instance_id.object_index) == obj_interaction_point || _point_instance_id.object_index == obj_interaction_point)) {
            if (_point_instance_id.is_occupied_by_pop_id == noone) {
                if (_required_type_tag == "" || (_required_type_tag != "" && variable_instance_exists(_point_instance_id, "interaction_type_tag") && _point_instance_id.interaction_type_tag == _required_type_tag)) {
                    return true; // Found a free slot (optionally matching tag)
                }
            }
        }
    }
    return false; // No free slot found

}
