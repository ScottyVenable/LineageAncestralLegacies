/// scr_pop_hauling.gml
///
/// Purpose:
///   Manages the behavior of a pop when it is in the HAULING state.
///   The pop will find a designated drop-off location (obj_structure_gatheringHut),
///   move to it, and deposit all haulable items from its inventory into the
///   global lineage stock.
///
/// Metadata:
///   Summary:       Pop behavior script for hauling items to a drop-off.
///   Usage:         Called by scr_pop_behavior when obj_pop.state == PopState.HAULING.
///                  Executed in the context of an obj_pop instance.
///   Parameters:    none (operates on 'self')
///   Returns:       void
///   Tags:          [pop_behavior][hauling][inventory][resource_management][ai]
///   Version:       1.0 - [Current Date]
///   Dependencies:  obj_pop instance variables (inventory_items, target_object_id, travel_point_x/y, state),
///                  obj_structure_gatheringHut (object type for drop-off),
///                  Item enum (scr_items.gml), get_item_data() (scr_items.gml),
///                  Global lineage stock variables (e.g., global.lineage_food_stock),
///                  PopState enum.

// This script is intended to be called from scr_pop_behavior like:
// case PopState.HAULING:
//     scr_pop_hauling();
// break;

function scr_pop_hauling() {
    // This script runs in the context of an obj_pop instance (self)

    // =========================================================================
    // 0. TARGET ACQUISITION
    // =========================================================================
    // If target_object_id is noone, it means we just entered HAULING state or lost our target.
    // We need to find a drop-off point.
    if (target_object_id == noone || !instance_exists(target_object_id) || target_object_id.object_index != obj_structure_gatheringHut) {
        // Check if pop has anything to haul
        if (!variable_instance_exists(id, "inventory_items") || ds_list_empty(inventory_items)) {
            show_debug_message("Pop " + string(id) + " (" + pop_name + ") in HAULING state but has empty inventory. Switching to IDLE.");
            state = PopState.IDLE;
            exit; // Nothing to haul
        }

        // Find the nearest gathering hut
        target_object_id = instance_nearest(x, y, obj_structure_gatheringHut);

        if (!instance_exists(target_object_id)) {
            show_debug_message("Pop " + string(id) + " (" + pop_name + ") in HAULING state: No obj_structure_gatheringHut found. Waiting or Idling.");
            // What to do if no hut exists? For now, switch to WAITING.
            // Could also make them wander or try again later.
            state = PopState.WAITING;
            is_waiting = true; // Ensure it waits
            exit;
        } else {
            show_debug_message("Pop " + string(id) + " (" + pop_name + ") found gathering hut " + string(target_object_id) + " to haul to.");
            // Set travel point to the hut's location
            travel_point_x = target_object_id.x;
            travel_point_y = target_object_id.y;
            has_arrived = false; // CRITICAL: Pop needs to move to this new travel_point
            speed = pop.base_speed / 1.2; // Set speed for hauling
            
            // Ensure sprite is walking and direction is towards the hut
            direction = point_direction(x, y, travel_point_x, travel_point_y);
            if (script_exists(scr_update_walk_sprite)) {
                scr_update_walk_sprite(); // Update walking animation based on new direction
            } else if (sprite_index != spr_man_walk) { 
                sprite_index = spr_man_walk;
                image_speed = 1;
            }
        }
    }

    // =========================================================================
    // 1. MOVEMENT TO TARGET DROP-OFF (Gathering Hut)
    // =========================================================================
    // This section should only run if the pop has not yet arrived at the travel_point_x, travel_point_y
    if (!has_arrived && instance_exists(target_object_id)) { // Check has_arrived and if target still exists
        var _dist_to_target = point_distance(x, y, travel_point_x, travel_point_y);
        // Arrival threshold should be small enough to ensure pop is at the hut
        // but large enough to prevent overshooting or getting stuck.
        var _arrival_threshold = pop.base_speed / 1.2 + 2; // e.g. slightly more than one step

        if (_dist_to_target > _arrival_threshold) {
            // Still moving to the hut
            var _dir = point_direction(x, y, travel_point_x, travel_point_y);
            // Speed is already set when target was acquired, or should be if state is HAULING
            // Ensure speed is not zero if it was reset by another state
            if (speed == 0) speed = pop.base_speed / 1.2;

            x += lengthdir_x(speed, _dir);
            y += lengthdir_y(speed, _dir);
            
            direction = _dir; 
			scr_update_walk_sprite();
            
            exit; // IMPORTANT: Still moving, so exit script for this step. State remains HAULING.
        } else {
            // Arrived at the hut's vicinity
            x = travel_point_x; // Snap to exact position
            y = travel_point_y;
            has_arrived = true; // Mark as arrived at the hut
            speed = 0; // Stop moving
            show_debug_message("Pop " + string(id) + " (" + pop_name + ") arrived at gathering hut " + string(target_object_id) + ". Preparing to drop off items.");
            // Sprite will be set to idle/depositing in the next block
        }
    }

    // =========================================================================
    // 2. PERFORM DROP-OFF (Only if arrived at the hut)
    // =========================================================================
    if (has_arrived && instance_exists(target_object_id) && target_object_id.object_index == obj_structure_gatheringHut) {
        // --- Perform Drop-off Logic (Sprite, Slot, Inventory) ---
        if (sprite_index != spr_man_idle) { 
            sprite_index = spr_man_idle; 
            image_index = 0;
        }

        // --- Find and claim a unique drop-off slot at the hut ---
        // This slot logic might need refinement if pops are to move to specific slots for dropping off
        // For now, it seems to be more about managing access rather than precise positioning for drop-off itself.
        // If _hauling_slot_index is not yet set, or was lost, try to get one.
        if (!variable_instance_exists(id, "_hauling_slot_index") || _hauling_slot_index == -1) {
            var slot_found = false;
            if (variable_instance_exists(target_object_id, "dropoff_slots")) {
                for (var i = 0; i < target_object_id.max_dropoff_slots; i++) {
                    var slot = target_object_id.dropoff_slots[i];
                    if (slot.claimed_by == noone) {
                        target_object_id.dropoff_slots[i].claimed_by = id;
                        _hauling_slot_index = i;
                        slot_found = true;
                        // Optional: if slots have positions, pop could move to slot.x, slot.y
                        // travel_point_x = target_object_id.x + slot.rel_x;
                        // travel_point_y = target_object_id.y + slot.rel_y;
                        // has_arrived = false; // Would require another movement step to the slot
                        // exit; // If moving to a specific slot position
                        break;
                    }
                }
            }
            if (!slot_found) {
                // No free slot, maybe wait or drop nearby? For now, proceed with drop-off at hut center.
                show_debug_message("Pop " + string(id) + " (" + pop_name + ") could not claim a drop-off slot at " + string(target_object_id) + ". Dropping items anyway.");
                _hauling_slot_index = -1; // Ensure it's marked as no slot claimed
            }
        }

        // Iterate through pop's inventory and add to global stock
        if (variable_instance_exists(id, "inventory_items") && !ds_list_empty(inventory_items)) {
            for (var i = ds_list_size(inventory_items) - 1; i >= 0; i--) { // Iterate backwards if removing
                var item_stack_struct = inventory_items[| i];
                var item_enum = item_stack_struct.item_id_enum;
                var item_qty = item_stack_struct.quantity;
                var item_data = get_item_data(item_enum);
                
                if (item_data != undefined) {
                    show_debug_message("Pop " + string(id) + " dropping off " + string(item_qty) + " of " + item_data.name + ".");
                    // Add to appropriate global stock based on item type or specific enum
                    // This part needs to be robust based on your global variable names and item categories
                    switch (item_enum) {
                        case Item.FOOD_RED_BERRY:
                            global.lineage_food_stock += item_qty;
                            break;
                        case Item.MATERIAL_WOOD:
                            global.lineage_wood_stock += item_qty;
                            break;
                        case Item.MATERIAL_STONE:
                            global.lineage_stone_stock += item_qty;
                            break;
                        case Item.MATERIAL_METAL_ORE: // Assuming you added this global
                            global.lineage_metal_stock += item_qty;
                            break;
                        // Add cases for other haulable items
                        default:
                            show_debug_message("Item " + item_data.name + " is not designated for global stock in hauling script.");
                            // Optionally, don't remove it from inventory if it's not stockable
                            // For now, we assume all items in inventory are being hauled to general stock
                            break;
                    }
                }
            }
            // Clear the pop's inventory after dropping everything off
            ds_list_clear(inventory_items); 
            // self.current_inventory_weight = 0; // Reset if using weight system
            show_debug_message("Pop " + string(id) + " (" + pop_name + ") inventory cleared after hauling.");
        }

        // --- Release claimed slot after drop-off ---
        if (_hauling_slot_index != -1 && instance_exists(target_object_id) && variable_instance_exists(target_object_id, "dropoff_slots")) {
            // Ensure the slot index is valid before trying to access it
            if (_hauling_slot_index >= 0 && _hauling_slot_index < array_length(target_object_id.dropoff_slots)) {
                target_object_id.dropoff_slots[_hauling_slot_index].claimed_by = noone;
            } else {
                // Log if the slot index was somehow invalid, though it shouldn't be if claimed properly.
                show_debug_message("Pop " + string(id) + " (" + pop_name + ") had an invalid _hauling_slot_index (" + string(_hauling_slot_index) + ") when trying to release slot at " + string(target_object_id));
            }
            self._hauling_slot_index = -1; // Clear the pop's record of the slot.
        }

        // Hauling complete, reset target.
        target_object_id = noone;
        has_arrived = false; // Reset has_arrived as it's no longer relevant to the completed hauling task.
        
        var _pop_id_str_haul_finish = pop_identifier_string + " (ID:" + string(id) + ")"; // For logging
        show_debug_message("Pop " + _pop_id_str_haul_finish + " finished hauling. Attempting to resume previous task or idle directly.");

        // DEBUG LOG: Check context before calling resume script
        var _log_prev_state = variable_instance_exists(id, "previous_state") ? scr_get_state_name(previous_state) : "UNDEFINED";
        var _log_last_target = variable_instance_exists(id, "last_foraged_target_id") ? string(last_foraged_target_id) : "N/A";
        var _log_last_slot = variable_instance_exists(id, "last_foraged_slot_index") ? string(last_foraged_slot_index) : "N/A";
        var _log_last_type = variable_instance_exists(id, "last_foraged_type_tag") ? last_foraged_type_tag : "N/A";
        show_debug_message("Pop " + _pop_id_str_haul_finish + " PRE-RESUME CHECK (from Hauling): previous_state=" + _log_prev_state + 
                           ", last_foraged_target_id=" + _log_last_target + 
                           ", last_foraged_slot_index=" + _log_last_slot +
                           ", last_foraged_type_tag=" + _log_last_type + ".");

        // New method: Robust dynamic script call
        // LEARNING POINT: Always get the asset index for a script name first
        // before using it with script_exists or script_execute.
        var _resume_script_name = "scr_pop_resume_previous_or_idle";
        var _resume_script_asset_index = asset_get_index(_resume_script_name);
        
        show_debug_message("Pop " + _pop_id_str_haul_finish + ": (Hauling) Preparing to call " + _resume_script_name + ". Asset index: " + string(_resume_script_asset_index));

        // Check if the script asset was found and actually exists
        if (_resume_script_asset_index != -1 && script_exists(_resume_script_asset_index)) {
            show_debug_message("Pop " + _pop_id_str_haul_finish + ": (Hauling) Script '" + _resume_script_name + "' exists. Executing now.");
            script_execute(_resume_script_asset_index); // Execute the script by its asset index
            show_debug_message("Pop " + _pop_id_str_haul_finish + ": (Hauling) Finished executing '" + _resume_script_name + "'. New state: " + scr_get_state_name(state));
        } else {
            // Fallback if the script is somehow missing
            // This provides more specific error information.
            var _error_reason_msg = "Unknown error.";
            if (_resume_script_asset_index == -1) {
                _error_reason_msg = "asset_get_index(\'" + _resume_script_name + "\') returned -1 (script name not found in assets).";
            } else if (!script_exists(_resume_script_asset_index)) {
                _error_reason_msg = "script_exists(" + string(_resume_script_asset_index) + ") returned false (asset exists but is not a script or is invalid).";
            }
            show_debug_message("CRITICAL ERROR (Hauling Pop " + _pop_id_str_haul_finish + "): Script '" + _resume_script_name + "' (Index: " + string(_resume_script_asset_index) + ") not found or does not exist! Reason: " + _error_reason_msg + ". Defaulting to IDLE state.");
            state = PopState.IDLE;
            // Reset relevant variables for IDLE state if necessary
            target_object_id = noone;
            target_interaction_object_id = noone;
            // Ensure last_foraged details are cleared if defaulting from a failed resume
            last_foraged_target_id = noone;
            last_foraged_slot_index = -1;
            last_foraged_type_tag = "";
        }
        
        exit; // Exit to allow the new state (set by resume/idle script) to take over in the next step.

    } else if (has_arrived && !instance_exists(target_object_id)) {
        // Target hut was lost AFTER arriving but BEFORE finishing drop-off (unlikely but possible)
        var _pop_id_str_lost_hut_post_arrive = pop_identifier_string + " (ID:" + string(id) + ")"; // For logging
        show_debug_message("Pop " + _pop_id_str_lost_hut_post_arrive + " lost target hut " + string(target_object_id) + " after arriving. Attempting to resume/idle.");
        // Release slot if held (important to prevent deadlocks)
        if (variable_instance_exists(id, "_hauling_slot_index") && _hauling_slot_index != -1) {
            // Attempt to find the original hut instance if it was just destroyed this step.
            // This is a bit of a guess. If target_object_id was stored, we might use it.
            // For now, we assume we can't reliably get the hut instance back to release the slot.
            // Consider a global slot manager or more robust cleanup if this becomes an issue.
            self._hauling_slot_index = -1; // Mark slot as free on the pop's side
        }
        target_object_id = noone;
        
        // Robustly call scr_pop_resume_previous_or_idle
        var _resume_script_name_lost_hut_post = "scr_pop_resume_previous_or_idle";
        var _resume_script_idx_lost_hut = asset_get_index(_resume_script_name_lost_hut_post);
        if (_resume_script_idx_lost_hut != -1 && script_exists(_resume_script_idx_lost_hut)) {
            show_debug_message("Pop " + _pop_id_str_lost_hut_post_arrive + " (lost hut post-arrival) calling " + _resume_script_name_lost_hut_post + " (index: " + string(_resume_script_idx_lost_hut) + ").");
            script_execute(_resume_script_idx_lost_hut);
        } else {
            var _error_reason_lost_hut_post = (_resume_script_idx_lost_hut == -1) ? "asset_get_index failed for " + _resume_script_name_lost_hut_post : "script_exists failed for index " + string(_resume_script_idx_lost_hut);
            show_debug_message("ERROR (Hauling - lost hut post-arrival): " + _resume_script_name_lost_hut_post + " script not found (" + _error_reason_lost_hut_post + ")! Pop " + _pop_id_str_lost_hut_post_arrive + " defaulting to IDLE.");
            state = PopState.IDLE; // Fallback
        }
        exit;
    } else if (!instance_exists(target_object_id) && target_object_id != noone) { 
        // This case handles if the target_object_id was set (not noone), but the instance got destroyed
        // before the pop arrived at it.
        var _pop_id_str_lost_hut_pre_arrive = pop_identifier_string + " (ID:" + string(id) + ")"; // For logging
        show_debug_message("Pop " + _pop_id_str_lost_hut_pre_arrive + " target hut " + string(target_object_id) + " lost before arrival. Attempting to resume/idle.");
        target_object_id = noone; // Clear the lost target
        // Release slot if held (though unlikely to be held if not arrived)
        if (variable_instance_exists(id, "_hauling_slot_index") && _hauling_slot_index != -1) {
             self._hauling_slot_index = -1;
        }
        
        // Robustly call scr_pop_resume_previous_or_idle
        var _resume_script_name_lost_hut_pre = "scr_pop_resume_previous_or_idle";
        var _resume_script_idx_lost_hut_pre = asset_get_index(_resume_script_name_lost_hut_pre);
        if (_resume_script_idx_lost_hut_pre != -1 && script_exists(_resume_script_idx_lost_hut_pre)) {
            show_debug_message("Pop " + _pop_id_str_lost_hut_pre_arrive + " (lost hut pre-arrival) calling " + _resume_script_name_lost_hut_pre + " (index: " + string(_resume_script_idx_lost_hut_pre) + ").");
            script_execute(_resume_script_idx_lost_hut_pre);
        } else {
            var _error_reason_pre_lost_hut = (_resume_script_idx_lost_hut_pre == -1) ? "asset_get_index failed for " + _resume_script_name_lost_hut_pre : "script_exists failed for index " + string(_resume_script_idx_lost_hut_pre);
            show_debug_message("ERROR (Hauling - lost hut pre-arrival): " + _resume_script_name_lost_hut_pre + " script not found (" + _error_reason_pre_lost_hut + ")! Pop " + _pop_id_str_lost_hut_pre_arrive + " defaulting to IDLE.");
            state = PopState.IDLE; // Fallback
        }
        exit;
    }
    // If none of the above conditions are met (e.g., still moving to hut, or some other edge case),
    // the script will naturally exit, and scr_pop_hauling will be called again in the next step.
}