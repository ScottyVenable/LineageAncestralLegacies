\
/// scr_pop_resume_previous_or_idle.gml
///
/// Purpose:
///   Attempts to resume the pop's 'previous_state' if it was a complex task (e.g., FORAGING).
///   If resumption fails or 'previous_state' was simple or undefined, sets an appropriate
///   fallback state (like IDLE or the simple previous_state).
///
/// Usage:
///   Called when a pop completes an action (like a commanded move or failed hauling)
///   and needs to decide its next state based on prior context.
///   Operates on 'self' (the pop instance).
///
/// Dependencies:
///   Pop instance variables: previous_state, last_foraged_target_id, state, target_object_id, etc.
///   Interaction scripts: scr_interaction_slot_get_available, scr_interaction_slot_claim
///   Objects: obj_redBerryBush
///   Enums: PopState
///   Utility: scr_get_state_name (for logging)

function scr_pop_resume_previous_or_idle() {
    // This script runs in the context of an obj_pop instance (self)
    var _pop_id_str = pop_identifier_string + " (ID:" + string(id) + ")"; // For logging

    if (variable_instance_exists(id, "previous_state") && previous_state != undefined) {
        var _task_resumed = false;
        var _original_previous_state_for_log = previous_state;
        var _attempt_foraging_resume = (previous_state == PopState.FORAGING);

        debug_log("Pop " + _pop_id_str + " entering resume script. Previous state: " + scr_get_state_name(_original_previous_state_for_log) + 
                  ". Last Foraged Target: " + (variable_instance_exists(id, "last_foraged_target_id") ? string(last_foraged_target_id) : "N/A") +
                  ", Slot: " + (variable_instance_exists(id, "last_foraged_slot_index") ? string(last_foraged_slot_index) : "N/A") +
                  ", Type: " + (variable_instance_exists(id, "last_foraged_type_tag") ? last_foraged_type_tag : "N/A"),
                  "scr_pop_resume", "blue");

        // --- Attempt to resume FORAGING ---
        if (_attempt_foraging_resume) {
            debug_log("Pop " + _pop_id_str + " attempting to resume FORAGING.", "scr_pop_resume", "blue");
            var _pop_instance = id;

            // 1. Check the last specific resource the pop was foraging from
            if (variable_instance_exists(_pop_instance, "last_foraged_target_id") &&
                _pop_instance.last_foraged_target_id != noone &&
                instance_exists(_pop_instance.last_foraged_target_id)) {
                
                var _specific_target_id = _pop_instance.last_foraged_target_id;
                var _target_object_name = object_get_name(_specific_target_id.object_index);
                debug_log("Pop " + _pop_id_str + " checking last specific target: " + _target_object_name + "(" + string(_specific_target_id) + ")", "scr_pop_resume", "blue");

                // Ensure the last_foraged_target_id is actually a resource provider (e.g. obj_redBerryBush)
                // This check might need to be more generic if pops can forage from different object types.
                // For now, we assume it's something like obj_redBerryBush which has these variables.
                if (!object_is_ancestor(_specific_target_id.object_index, par_slot_provider)) {
                     debug_log("Pop " + _pop_id_str + " last_foraged_target_id " + _target_object_name + "(" + string(_specific_target_id) + ") is not a par_slot_provider. Cannot resume foraging at it.", "scr_pop_resume", "orange");
                } else {
                    // Attempt to reclaim the *exact* same slot if possible and sensible, or any slot if not.
                    // For simplicity, we'll try to get *any* available slot on this specific target first.
                    // The 'last_foraged_slot_index' and 'last_foraged_type_tag' could be used for more precise resumption.
                    
                    with (_specific_target_id) { // Scope to the specific target instance
                        if (variable_instance_exists(id, "is_harvestable") && is_harvestable &&
                            variable_instance_exists(id, "resource_count") && resource_count > 0) {
                            
                            if (script_exists(asset_get_index("scr_interaction_slot_get_available")) && script_exists(asset_get_index("scr_interaction_slot_claim"))) {
                                var _slot_get_idx = asset_get_index("scr_interaction_slot_get_available");
                                var _slot_claim_idx = asset_get_index("scr_interaction_slot_claim");

                                var slot_info = script_execute(_slot_get_idx, id); // 'id' here is _specific_target_id
                                if (slot_info != undefined) {
                                    debug_log("Pop " + _pop_id_str + " found available slot " + string(slot_info.slot_index) + " at specific target " + _target_object_name + "(" + string(id) + "). Attempting to claim.", "scr_pop_resume", "blue");
                                    if (script_execute(_slot_claim_idx, id, slot_info.slot_index, _pop_instance.id, slot_info.type_tag)) { // Pass type_tag
                                        _pop_instance.target_object_id = id;
                                        _pop_instance.target_interaction_object_id = id;
                                        _pop_instance.target_interaction_slot_index = slot_info.slot_index;
                                        _pop_instance.target_interaction_type_tag = slot_info.type_tag; // Store the type tag from the claimed slot
                                        _pop_instance.travel_point_x = slot_info.world_x;
                                        _pop_instance.travel_point_y = slot_info.world_y;
                                        _pop_instance.state = PopState.FORAGING;
                                        _pop_instance.has_arrived = false;
                                        _task_resumed = true;
                                        debug_log("Pop " + _pop_id_str + " RESUMED FORAGING at previous target " + _target_object_name + "(" + string(id) + ") slot " + string(slot_info.slot_index) + " type: " + slot_info.type_tag, "scr_pop_resume", "green");
                                    } else {
                                        debug_log("Pop " + _pop_id_str + " FAILED to claim slot " + string(slot_info.slot_index) + " at specific target " + _target_object_name + "(" + string(id) + ").", "scr_pop_resume", "orange");
                                    }
                                } else {
                                    debug_log("Pop " + _pop_id_str + " found NO available slots at specific target " + _target_object_name + "(" + string(id) + ").", "scr_pop_resume", "orange");
                                }
                            } else {
                                debug_log("Pop " + _pop_id_str + " slot interaction scripts not found for specific target check!", "scr_pop_resume", "red");
                            }
                        } else {
                            debug_log("Pop " + _pop_id_str + " specific target " + _target_object_name + "(" + string(id) + ") is no longer harvestable or has no resources.", "scr_pop_resume", "orange");
                        }
                    }
                }
            } else {
                 var reason = "last_foraged_target_id not set";
                 if (variable_instance_exists(_pop_instance, "last_foraged_target_id")) {
                     if (_pop_instance.last_foraged_target_id == noone) reason = "last_foraged_target_id is noone";
                     else if (!instance_exists(_pop_instance.last_foraged_target_id)) reason = "last_foraged_target_id instance (" + string(_pop_instance.last_foraged_target_id) + ") no longer exists";
                 }
                 debug_log("Pop " + _pop_id_str + " cannot check specific last target. Reason: " + reason, "scr_pop_resume", "orange");
            }

            // 2. If not resumed at the specific target, search for any other nearby valid resource
            //    For now, this specifically searches for obj_redBerryBush. This could be expanded.
            if (!_task_resumed) {
                debug_log("Pop " + _pop_id_str + " did not resume at specific target. Searching for NEW nearby obj_redBerryBush.", "scr_pop_resume", "blue");
                var search_radius = 200; 

                // Find the closest, available, harvestable resource of the type obj_redBerryBush
                var closest_target_id = noone;
                var min_dist = search_radius + 1; // Start with a distance greater than search_radius

                with (obj_redBerryBush) { // Iterate through all berry bushes
                    // Skip if this is the same bush we specifically (and unsuccessfully) checked above
                    if (variable_instance_exists(_pop_instance, "last_foraged_target_id") && id == _pop_instance.last_foraged_target_id) {
                        continue; 
                    }

                    if (variable_instance_exists(id, "is_harvestable") && is_harvestable &&
                        variable_instance_exists(id, "resource_count") && resource_count > 0) {
                        
                        // Check if this bush has any available slot *before* checking distance
                        // This is slightly less efficient if many bushes, but clearer for now.
                        var temp_slot_info = undefined;
                        if (script_exists(asset_get_index("scr_interaction_slot_get_available"))) {
                            var _slot_get_idx = asset_get_index("scr_interaction_slot_get_available");
                            temp_slot_info = script_execute(_slot_get_idx, id);
                        }

                        if (temp_slot_info != undefined) { // Bush has an available slot
                            var dist_to_target = point_distance(_pop_instance.x, _pop_instance.y, x, y);
                            if (dist_to_target <= search_radius && dist_to_target < min_dist) {
                                min_dist = dist_to_target;
                                closest_target_id = id;
                            }
                        }
                    }
                } // end with (obj_redBerryBush)

                if (instance_exists(closest_target_id)) {
                    var _target_object_name = object_get_name(closest_target_id.object_index);
                    debug_log("Pop " + _pop_id_str + " found closest new target: " + _target_object_name + "(" + string(closest_target_id) + ") at dist " + string(min_dist) + ". Attempting to claim slot.", "scr_pop_resume", "blue");
                    
                    // Now, re-get and claim the slot on this chosen closest_target_id
                    // We re-get because another pop might have claimed it in the interim, though unlikely in a single step.
                    if (script_exists(asset_get_index("scr_interaction_slot_get_available")) && script_exists(asset_get_index("scr_interaction_slot_claim"))) {
                        var _slot_get_idx = asset_get_index("scr_interaction_slot_get_available");
                        var _slot_claim_idx = asset_get_index("scr_interaction_slot_claim");

                        var slot_info = script_execute(_slot_get_idx, closest_target_id);
                        if (slot_info != undefined) {
                             if (script_execute(_slot_claim_idx, closest_target_id, slot_info.slot_index, _pop_instance.id, slot_info.type_tag)) { // Pass type_tag
                                _pop_instance.target_object_id = closest_target_id;
                                _pop_instance.target_interaction_object_id = closest_target_id;
                                _pop_instance.target_interaction_slot_index = slot_info.slot_index;
                                _pop_instance.target_interaction_type_tag = slot_info.type_tag; // Store the type tag
                                _pop_instance.travel_point_x = slot_info.world_x;
                                _pop_instance.travel_point_y = slot_info.world_y;
                                _pop_instance.state = PopState.FORAGING;
                                _pop_instance.has_arrived = false;
                                _task_resumed = true;
                                debug_log("Pop " + _pop_id_str + " RESUMED FORAGING at new nearby target " + _target_object_name + "(" + string(closest_target_id) + ") slot " + string(slot_info.slot_index) + " type: " + slot_info.type_tag, "scr_pop_resume", "green");
                            } else {
                                debug_log("Pop " + _pop_id_str + " FAILED to claim slot " + string(slot_info.slot_index) + " at new nearby target " + _target_object_name + "(" + string(closest_target_id) + ").", "scr_pop_resume", "orange");
                            }
                        } else {
                             debug_log("Pop " + _pop_id_str + " found NO available slots at new nearby target " + _target_object_name + "(" + string(closest_target_id) + ") (slot possibly taken between check and claim attempt).", "scr_pop_resume", "orange");
                        }
                    } else {
                         debug_log("Pop " + _pop_id_str + " slot interaction scripts not found for new nearby target check!", "scr_pop_resume", "red");
                    }
                } else {
                    debug_log("Pop " + _pop_id_str + " found NO suitable new obj_redBerryBush targets within radius " + string(search_radius) + ".", "scr_pop_resume", "orange");
                }
            }
        }
        // --- End of FORAGING resumption attempt ---
        // TODO: Add 'else if (previous_state == PopState.OTHER_COMPLEX_TASK_TYPE)' for other resumable tasks

        if (_task_resumed) {
            // A complex task (like Foraging) was successfully resumed.
            // State and targets are already set within the resumption logic.
            debug_log("Pop " + _pop_id_str + " successfully resumed previous task. New state: " + scr_get_state_name(state) + " (was " + scr_get_state_name(_original_previous_state_for_log) + ")", "scr_pop_resume", "green");
        } else {
            // Could not resume a complex task, or previous_state was simple.
            debug_log("Pop " + _pop_id_str + " FAILED to resume complex task or previous state was simple. Original previous state: " + scr_get_state_name(_original_previous_state_for_log), "scr_pop_resume", "orange");
            // Revert to the generic previous_state if it's safe to do so.
            if (_original_previous_state_for_log != PopState.FORAGING && // Avoid re-setting to foraging if it failed
                _original_previous_state_for_log != PopState.HAULING &&  // Avoid looping back to hauling
                _original_previous_state_for_log != PopState.COMMANDED) { // Avoid issues if COMMANDED was interrupted
                state = _original_previous_state_for_log;
                debug_log("Pop " + _pop_id_str + " (" + pop_name + ") reverted to simple previous_state: " + scr_get_state_name(state), "scr_pop_resume", "orange");
            } else {
                // Default fallback if previous state can't be simply resumed or was a complex one that failed.
                state = PopState.IDLE;
                debug_log("Pop " + _pop_id_str + " could not resume complex task (" + scr_get_state_name(_original_previous_state_for_log) + ") or previous state was unsafe. Defaulting to IDLE.", "scr_pop_resume", "orange");
            }
        }
        previous_state = undefined; // Clear/consume the stored previous state in all cases
        last_foraged_target_id = noone; // Clear last foraged target as it's either been resumed or deemed unsuitable
        last_foraged_slot_index = -1;
        last_foraged_type_tag = "";
        
        // If we defaulted to IDLE or a simple state without a specific target, clear any lingering interaction targets.
        if (!_task_resumed && (state == PopState.IDLE || state == PopState.WAITING || state == PopState.WANDERING)) {
             target_object_id = noone;
             target_interaction_object_id = noone;
             target_interaction_slot_index = -1;
             target_interaction_type_tag = ""; // Clear type tag as well
        }

    } else {
        // No previous_state was stored, or it was undefined. Default to IDLE.
        state = PopState.IDLE;
        target_object_id = noone; // Ensure no lingering target
        target_interaction_object_id = noone;
        target_interaction_slot_index = -1;
        target_interaction_type_tag = ""; // Clear type tag as well
        debug_log("Pop " + _pop_id_str + " had no previous_state. Defaulting to IDLE.", "scr_pop_resume", "orange");
    }
}
