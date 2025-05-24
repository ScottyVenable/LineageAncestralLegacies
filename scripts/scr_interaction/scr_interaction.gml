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
/// @function scr_interaction_slot_get_free(_target_object_id)
/// @description Finds and returns the index of a free interaction slot on a target object.
/// @param {Id.Instance} _target_object_id   The instance ID of the slot provider object.
/// @returns {Real} Index of a free slot, or -1 if no slots are free or target is invalid.
function scr_interaction_slot_get_free(_target_object_id) {
    if (!instance_exists(_target_object_id) || 
        !variable_instance_exists(_target_object_id, "interaction_slots_pop_ids")) {
        // show_debug_message($"Error (GetFreeSlot): Target object {_target_object_id} invalid or missing slot data.");
        return -1;
    }

    var _slots_array = _target_object_id.interaction_slots_pop_ids;
    for (var i = 0; i < array_length(_slots_array); i++) {
        if (_slots_array[i] == noone) {
            return i; // Return index of the first free slot
        }
    }
    // show_debug_message($"Info (GetFreeSlot): No free slots on target {_target_object_id}.");
    return -1; // No free slots found
}


// ============================================================================
// FUNCTION: scr_interaction_slot_claim
// ============================================================================
/// @function scr_interaction_slot_claim(_target_object_id, _slot_index, _pop_id)
/// @description Assigns a pop to a specific interaction slot on a target object.
/// @param {Id.Instance} _target_object_id   The instance ID of the slot provider object.
/// @param {Real}        _slot_index         The index of the slot to claim.
/// @param {Id.Instance} _pop_id             The instance ID of the pop claiming the slot.
/// @returns {Bool} True if the slot was successfully claimed, false otherwise.
function scr_interaction_slot_claim(_target_object_id, _slot_index, _pop_id) {
    if (instance_exists(_target_object_id) &&
        variable_instance_exists(_target_object_id, "interaction_slots_pop_ids") &&
        _slot_index >= 0 && _slot_index < array_length(_target_object_id.interaction_slots_pop_ids)) {
        
        // Check if the slot is actually free before claiming
        if (_target_object_id.interaction_slots_pop_ids[_slot_index] == noone) {
            _target_object_id.interaction_slots_pop_ids[_slot_index] = _pop_id;
            // show_debug_message($"Pop {_pop_id} claimed slot {_slot_index} on target {_target_object_id}");
            return true;
        } else {
            // show_debug_message($"Warning (ClaimSlot): Pop {_pop_id} tried to claim busy slot {_slot_index} on target {_target_object_id} (Occupied by: {_target_object_id.interaction_slots_pop_ids[_slot_index]}).");
            return false; // Slot was not free
        }
    }
    // show_debug_message($"Warning (ClaimSlot): Failed to claim slot {_slot_index} on target {_target_object_id} for pop {_pop_id}. Target or slot index invalid.");
    return false;
}


// ============================================================================
// FUNCTION: scr_interaction_slot_release
// ============================================================================
/// @function scr_interaction_slot_release(_target_object_id, _pop_id)
/// @description Releases an interaction slot previously occupied by a specific pop on a target object.
/// @param {Id.Instance} _target_object_id   The instance ID of the slot provider object.
/// @param {Id.Instance} _pop_id             The instance ID of the pop that is releasing the slot.
function scr_interaction_slot_release(_target_object_id, _pop_id) {
    if (!instance_exists(_target_object_id) || 
        !variable_instance_exists(_target_object_id, "interaction_slots_pop_ids") ||
        _pop_id == noone) { // Don't try to release if pop_id is invalid
        return;
    }

    var _slots_array = _target_object_id.interaction_slots_pop_ids;
    for (var i = 0; i < array_length(_slots_array); i++) {
        if (_slots_array[i] == _pop_id) {
            _slots_array[i] = noone;
            // show_debug_message($"Pop {_pop_id} released slot {i} from target {_target_object_id}");
            return; // Found and released the slot for this pop
        }
    }
    // show_debug_message($"Warning (ReleaseSlot): Pop {_pop_id} tried to release a slot from target {_target_object_id}, but was not found in any slot.");
}


// ============================================================================
// FUNCTION: scr_interaction_slot_get_world_pos
// ============================================================================
/// @function scr_interaction_slot_get_world_pos(_target_object_id, _slot_index)
/// @description Calculates the world x,y coordinates and interaction type tag of a specific interaction slot.
/// @param {Id.Instance} _target_object_id   The instance ID of THE slot provider object.
/// @param {Real}        _slot_index         The index of the slot.
/// @returns {Struct|Undefined} A struct { x: world_x, y: world_y, type_tag: string } or undefined if invalid.
function scr_interaction_slot_get_world_pos(_target_object_id, _slot_index) {
    if (instance_exists(_target_object_id) &&
        variable_instance_exists(_target_object_id, "interaction_slot_positions") &&
        _slot_index >= 0 && _slot_index < array_length(_target_object_id.interaction_slot_positions)) {
        
        var _slot_data_struct = _target_object_id.interaction_slot_positions[_slot_index];
        
        // Ensure the slot data struct has the expected members
        if (!is_struct(_slot_data_struct) || 
            !variable_struct_exists(_slot_data_struct, "rel_x") ||
            !variable_struct_exists(_slot_data_struct, "rel_y") ||
            !variable_struct_exists(_slot_data_struct, "interaction_type_tag")) {
            show_debug_message($"Error (GetWorldPos): Slot data struct for slot {_slot_index} on target {_target_object_id} is malformed.");
            return undefined;
        }
            
        return {
            x: _target_object_id.x + _slot_data_struct.rel_x,
            y: _target_object_id.y + _slot_data_struct.rel_y,
            type_tag: _slot_data_struct.interaction_type_tag
        };
    }
    // show_debug_message($"Error (GetWorldPos): Invalid target {_target_object_id} or slot index {_slot_index} for slot position.");
    return undefined;
}

// ============================================================================
// FUNCTION: scr_interaction_slot_acquire
// ============================================================================
/// @function scr_interaction_slot_acquire(_target_object_id, _pop_id, [_preferred_slot_index=-1], [_required_type_tag=""])
/// @description Attempts to find and claim an interaction slot on a target object.
///              Can prioritize a specific slot or search for any available slot,
///              optionally matching a specific interaction type tag.
/// @param {Id.Instance} _target_object_id      The instance ID of the slot provider object.
/// @param {Id.Instance} _pop_id                The instance ID of the pop attempting to acquire the slot.
/// @param {Real}        [_preferred_slot_index=-1] Optional. The specific slot index to try first. If -1, searches all.
/// @param {String}      [_required_type_tag=""] Optional. The interaction_type_tag the slot must have. If empty, any tag is fine.
/// @returns {Struct} A struct with the following fields:
///                   { success: Boolean, slot_index: Real, world_x: Real, world_y: Real, type_tag: String }
///                   \'success\' is true if a slot was acquired, false otherwise.
///                   \'slot_index\' is the index of the acquired slot (-1 if none).
///                   \'world_x\', \'world_y\' are the world coordinates of the acquired slot.
///                   \'type_tag\' is the interaction_type_tag of the acquired slot.
function scr_interaction_slot_acquire(_target_object_id, _pop_id, _preferred_slot_index = -1, _required_slot_type_tag = "") {
    // Basic validation
    if (!instance_exists(_target_object_id) ||
        !variable_instance_exists(_target_object_id, "interaction_slots_pop_ids") ||
        !variable_instance_exists(_target_object_id, "interaction_slot_positions")) {
        show_debug_message($"ERROR (SlotAcquire): Target {_target_object_id} invalid or missing slot data.");
        return { success: false, slot_index: -1, world_x: 0, world_y: 0, type_tag: "" };
    }
    if (!instance_exists(_pop_id)) {
        show_debug_message($"ERROR (SlotAcquire): Pop ID {_pop_id} invalid.");
        return { success: false, slot_index: -1, world_x: 0, world_y: 0, type_tag: "" };
    }

    var _slots_pop_ids = _target_object_id.interaction_slots_pop_ids;
    var _slot_positions = _target_object_id.interaction_slot_positions;

    // Helper function to check and claim a specific slot
    // Now accepts _current_slots_pop_ids and _current_slot_positions as arguments
    var _try_claim_slot = function(_slot_idx, _current_slots_pop_ids, _current_slot_positions) {
        // Access array_length of the passed _current_slots_pop_ids array
        if (_slot_idx < 0 || _slot_idx >= array_length(_current_slots_pop_ids)) return undefined; // Invalid index

        // Check if slot is free using the passed _current_slots_pop_ids
        if (_current_slots_pop_ids[_slot_idx] != noone) return undefined; // Slot not free

        // Check type tag if required, using the passed _current_slot_positions
        var _slot_data_struct = _current_slot_positions[_slot_idx];
        if (!is_struct(_slot_data_struct) || !variable_struct_exists(_slot_data_struct, "interaction_type_tag")) {
             show_debug_message($"Warning (SlotAcquire): Slot data for index {_slot_idx} on target {_target_object_id} is malformed.");
             return undefined; // Malformed slot data
        }
        var _current_slot_type_tag = _slot_data_struct.interaction_type_tag;
        if (_required_slot_type_tag != "" && _current_slot_type_tag != _required_slot_type_tag) {
            return undefined; // Type tag mismatch
        }

        // Try to claim
        if (scr_interaction_slot_claim(_target_object_id, _slot_idx, _pop_id)) {
            var _world_pos_data = scr_interaction_slot_get_world_pos(_target_object_id, _slot_idx);
            if (!is_undefined(_world_pos_data)) {
                 show_debug_message($"INFO (SlotAcquire): Pop {_pop_id} acquired slot {_slot_idx} (Tag: \'{_current_slot_type_tag}\') on target {_target_object_id}.");
                return {
                    success: true,
                    slot_index: _slot_idx,
                    world_x: _world_pos_data.x,
                    world_y: _world_pos_data.y,
                    type_tag: _current_slot_type_tag
                };
            } else {
                // This should ideally not happen if claim was successful and data is consistent
                show_debug_message($"ERROR (SlotAcquire): Claimed slot {_slot_idx} but failed to get world position.");
                // Release the claim as we can\'t return full data
                scr_interaction_slot_release(_target_object_id, _pop_id); 
                return undefined;
            }
        }
        return undefined; // Claim failed
    }

    // 1. Try preferred slot index first
    if (_preferred_slot_index != -1) {
        // Pass _slots_pop_ids and _slot_positions to the helper function
        var _claimed_details = _try_claim_slot(_preferred_slot_index, _slots_pop_ids, _slot_positions);
        if (!is_undefined(_claimed_details)) {
            return _claimed_details;
        }
        // If preferred slot claim failed (e.g. busy, wrong tag), continue to search all.
    }

    // 2. Iterate through all slots to find a suitable one
    for (var i = 0; i < array_length(_slots_pop_ids); i++) {
        // Don't re-try the preferred slot if it was already attempted and failed
        if (_preferred_slot_index != -1 && i == _preferred_slot_index) continue;
        
        // Pass _slots_pop_ids and _slot_positions to the helper function
        var _claimed_details = _try_claim_slot(i, _slots_pop_ids, _slot_positions);
        if (!is_undefined(_claimed_details)) {
            return _claimed_details;
        }
    }

    // 3. No suitable slot found or claimed
    show_debug_message($"INFO (SlotAcquire): Pop {_pop_id} failed to acquire any slot (Tag req: \'{_required_slot_type_tag}\') on target {_target_object_id}.");
    return { success: false, slot_index: -1, world_x: 0, world_y: 0, type_tag: "" };
}

// ============================================================================
// FUNCTION: scr_interaction_slot_has_available
// ============================================================================
/// @function scr_interaction_slot_has_available(_target_object_id)
/// @description Checks if a given target object (which is expected to be a slot provider)
///              has at least one unoccupied interaction slot.
/// @param {Id.Instance} _target_object_id   The instance ID of the slot provider object.
/// @returns {Bool} True if at least one slot is available, false otherwise.
function scr_interaction_slot_has_available(_target_object_id) {
    // --- Validate Target Object --- 
    // First, ensure the target object actually exists.
    if (!instance_exists(_target_object_id)) {
        show_debug_message("ERROR (scr_interaction_slot_has_available): Target object " + string(_target_object_id) + " does not exist.");
        return false; // Cannot check slots on a non-existent object.
    }

    // Second, check if the target object has the necessary array for tracking pop IDs in slots.
    // This array is crucial for determining if a slot is occupied.
    if (!variable_instance_exists(_target_object_id, "interaction_slots_pop_ids")) {
        show_debug_message("ERROR (scr_interaction_slot_has_available): Target object " + object_get_name(_target_object_id.object_index) + "(" + string(_target_object_id) + ") is missing 'interaction_slots_pop_ids' array.");
        return false; // If the array is missing, we can't determine slot availability.
    }

    // --- Check for Available Slots --- 
    // Get a direct reference to the array that stores which pop is in which slot.
    var _slots_pop_ids = _target_object_id.interaction_slots_pop_ids;
    var _num_slots = array_length(_slots_pop_ids);

    // If there are no slots defined at all, then none are available.
    if (_num_slots == 0) {
        show_debug_message("WARNING (scr_interaction_slot_has_available): Target object " + object_get_name(_target_object_id.object_index) + "(" + string(_target_object_id) + ") has an empty 'interaction_slots_pop_ids' array (0 slots defined).");
        return false;
    }

    // LEARNING POINT: We iterate through the `interaction_slots_pop_ids` array.
    // Each element in this array should store the ID of the pop occupying that slot,
    // or a value like 'noone' or -1 if the slot is free.
    for (var i = 0; i < _num_slots; i++) {
        // If an element in the array is 'noone' (or your chosen indicator for an empty slot),
        // it means this slot is available.
        if (_slots_pop_ids[i] == noone) { 
            // For debugging, you could uncomment this:
            // show_debug_message("Slot " + string(i) + " on target " + string(_target_object_id) + " is available.");
            return true; // Found an available slot, no need to check further.
        }
    }

    // If the loop completes without finding any slot marked as 'noone',
    // it means all slots are currently occupied.
    // show_debug_message("Target " + object_get_name(_target_object_id.object_index) + "(" + string(_target_object_id) + ") has no available interaction slots."); // This can be noisy, consider removing or conditionalizing
    return false; // No available slots found.
}

// ============================================================================
// SCRIPT INITIALIZATION CONFIRMATION (Optional)
// ============================================================================
// This show_debug_message will run once when the script is first compiled.
// show_debug_message("Script Initialized: scr_interaction (Slot Management Utilities)");