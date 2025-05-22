/// scr_pop_foraging.gml (or scr_pop_interaction_work.gml)
///
/// Purpose:
///   Handles the behavior for a pop that is tasked with an interaction
///   at a specific slot on a target object (e.g., foraging from a bush).
///   Manages movement to the slot, performing the interaction using correct
///   directional sprites, releasing the slot, and then stepping a short distance
///   away before transitioning to a commanded move to that spot (which then leads to WAITING).
///
/// Metadata:
///   Summary:       Move to slot, perform work, release slot, step away, then commanded to wait.
///   Usage:         Called by scr_pop_behavior when state is PopState.FORAGING (or a generic WORKING state).
///   Version:       1.4 - [Current Date] (Pop steps away from bush after foraging by setting a new commanded move)
///   Dependencies:  scr_interaction_slot_get_world_pos, scr_interaction_slot_release,
///                  scr_update_walk_sprite, scr_inventory_struct_add, PopState (enum),
///                  Instance variables: target_interaction_object_id, target_interaction_slot_index, etc.

function scr_pop_foraging() { // Consider renaming to scr_pop_perform_interaction() or scr_pop_work_at_slot()

    // =========================================================================
    // 0. VALIDATION: Ensure Target Object & Slot Info Are Valid
    // =========================================================================
    #region 0.1 Validate Interaction Target
    if (!instance_exists(target_interaction_object_id) || 
        target_interaction_slot_index == -1 || // Check if a slot was assigned
        !variable_instance_exists(target_interaction_object_id, "interaction_slot_positions") || // Target must be a slot provider
        target_interaction_slot_index >= array_length(target_interaction_object_id.interaction_slot_positions)) { // Slot index must be valid

        // If target is somehow invalid, try to release slot if pop thought it had one
        if (instance_exists(target_interaction_object_id) && target_interaction_slot_index != -1 &&
            variable_instance_exists(target_interaction_object_id, "interaction_slots_pop_ids")) { // Ensure array exists before access
             scr_interaction_slot_release(target_interaction_object_id, id);
        }
        
        // Reset pop's interaction variables and go to WAITING state
        target_interaction_object_id = noone;
        target_interaction_slot_index = -1;
        target_interaction_type_tag = "";
        state = PopState.WAITING; 
        is_waiting = true; 
        depth = -y; 
        has_arrived = true; // Since it's waiting at its current spot
        speed = pop.base_speed;
        image_speed = 1.0; 
        sprite_index = spr_man_idle; // Default to idle sprite
        show_debug_message($"Pop {pop_identifier_string} (ID: {id}) has invalid interaction target/slot. Reverting to WAITING.");
        exit;
    }
    #endregion

    // Get target slot's current world position (in case target object moved)
    var _slot_details = scr_interaction_slot_get_world_pos(target_interaction_object_id, target_interaction_slot_index);
    
    if (_slot_details == undefined) {
        show_debug_message($"Pop {pop_identifier_string} (ID: {id}) could not retrieve slot details for target {target_interaction_object_id}, slot {target_interaction_slot_index}. Reverting to WAITING.");
        // Attempt to release slot even if details are bad, as pop *thinks* it has a slot
        if (instance_exists(target_interaction_object_id) && target_interaction_slot_index != -1) {
            scr_interaction_slot_release(target_interaction_object_id, id);
        }
        target_interaction_object_id = noone; target_interaction_slot_index = -1; target_interaction_type_tag = "";
        state = PopState.WAITING; is_waiting = true; depth = -y; has_arrived = true; speed = 0; image_speed = 1.0; sprite_index = spr_man_idle;
        exit;
    }
    var _slot_target_x = _slot_details.x;
    var _slot_target_y = _slot_details.y;

    // =========================================================================
    // 1. MOVEMENT TO ASSIGNED SLOT (if not already there)
    // =========================================================================
    #region 1.1 Movement to Slot
    if (!has_arrived) { // 'has_arrived' means arrived at the interaction SLOT
        depth = target_interaction_object_id.depth - 1; // Pop appears in front of target while approaching
        
        if (point_distance(x, y, _slot_target_x, _slot_target_y) >= 2) { // Movement threshold
            direction = point_direction(x, y, _slot_target_x, _slot_target_y);
            speed = 1.5; // Movement speed towards slot
            image_speed = 1.5; // Walking animation speed
            scr_update_walk_sprite(); // Update walking animation
            exit; // Still moving to slot, exit script for this step
        } else {
            // Arrived at the slot
            x = _slot_target_x;
            y = _slot_target_y;
            speed = 0;
            has_arrived = true; // Now at the slot
            image_speed = 1.0;  // Reset animation speed, foraging anim will use its own or this base
            
            // Reset task-specific timer upon arrival at slot, based on interaction type
            if (target_interaction_type_tag == "forage_left" || target_interaction_type_tag == "forage_right") {
                forage_timer = 0;
            }
            // else if (target_interaction_type_tag == "mine_rock") { mining_timer = 0; } // Example
            
            show_debug_message($"Pop {pop_identifier_string} (ID: {id}) arrived at slot {target_interaction_slot_index} for target {target_interaction_object_id}. Type: '{target_interaction_type_tag}'.");
        }
    }
    #endregion

    // If we've reached here, pop 'has_arrived' at the interaction slot and 'speed' is 0.
    // =========================================================================
    // 2. PERFORMING INTERACTION AT SLOT (Logic branches based on type_tag)
    // =========================================================================
    #region 2.1 Interaction Logic
    // Ensure pop is correctly positioned (already at slot) and facing the target object's center
    depth = target_interaction_object_id.depth - 1; // Keep pop in front while working
    direction = point_direction(x, y, target_interaction_object_id.x, target_interaction_object_id.y);

    // --- Branch logic based on target_interaction_type_tag ---
    switch (target_interaction_type_tag) {
        case "forage_left": // SLOT is on the LEFT of the bush
            sprite_index = spr_man_foraging_right; // Pop FACES RIGHT (towards bush)
            // Foraging animation speed uses sprite's default if image_speed was reset to 1.0 on arrival.
            break; 
        case "forage_right": // SLOT is on the RIGHT of the bush
            sprite_index = spr_man_foraging_left;  // Pop FACES LEFT (towards bush)
            // Foraging animation speed uses sprite's default.
            break;
            
        // case "mine_rock_front": // Example for other tasks
        //     sprite_index = spr_man_mining_front; 
        //     // image_speed might be set if mining anim needs different speed from default
        //     break;
            
        default:
            // Unknown or generic interaction type tag
            sprite_index = spr_man_idle; // Fallback to idle animation
            image_speed = 0.2; // Example for a generic idle if no specific animation
            show_debug_message($"Pop {pop_identifier_string} (ID: {id}) at slot with unhandled tag: '{target_interaction_type_tag}'. Using fallback sprite.");
            break;
    }
    
    // --- Task-specific logic (e.g., Foraging progress) ---
    if (target_interaction_type_tag == "forage_left" || target_interaction_type_tag == "forage_right") {
        forage_timer += 1;
        if (forage_timer >= forage_rate) {
            forage_timer = 0; // Reset for next tick
            var _item_harvested_this_tick = false;
            var _target_is_depleted = false;

            // Interact with the target_interaction_object_id (which is a bush in this case)
            if (instance_exists(target_interaction_object_id) && 
                variable_instance_exists(target_interaction_object_id, "is_harvestable") &&
                target_interaction_object_id.is_harvestable &&
                variable_instance_exists(target_interaction_object_id, "berry_count")) {

                if (target_interaction_object_id.berry_count > 0) {
                    target_interaction_object_id.berry_count -= 1;
                    _item_harvested_this_tick = true;
					
					var berries_gathered_this_cycle = 1; // Or more, depending on skill/tool/bush yield
					var item_enum_to_add = Item.FOOD_RED_BERRY; // The enum for red berries

					// 'self' here refers to the obj_pop instance running this script
					if (!variable_instance_exists(id, "inventory_items")) {
					    // Safety: Initialize inventory if it somehow doesn't exist (should be in Create)
					    inventory_items = ds_list_create(); 
					    show_debug_message($"Warning: Pop {id} inventory_items not found, created new list.");
					}

					show_debug_message($"Pop {id} ({pop_name}) gathered {berries_gathered_this_cycle} berries. Attempting to add to inventory.");

					var berries_not_added = scr_inventory_add_item(self.inventory_items, item_enum_to_add, berries_gathered_this_cycle);

					if (berries_not_added > 0) {
					    show_debug_message($"Pop {id} inventory full or issue, {berries_not_added} berries dropped/lost.");
					    // TODO: Implement logic for dropping items on the ground if inventory is full
					}
					
					
                    if (target_interaction_object_id.berry_count == 0) {
                        target_interaction_object_id.is_harvestable = false;
                        if (sprite_exists(target_interaction_object_id.spr_empty)) { // Check sprite exists before assigning
                             target_interaction_object_id.sprite_index = target_interaction_object_id.spr_empty;
                        }
                        _target_is_depleted = true;
                    }
                } else { // berry_count is 0 or less
                    _target_is_depleted = true;
                    target_interaction_object_id.is_harvestable = false; // Ensure flag is set
                }
            } else { // Target doesn't exist, isn't harvestable, or doesn't have berry_count
                 _target_is_depleted = true; 
            }

            if (_item_harvested_this_tick) {
                scr_inventory_struct_add("berry", 1); // Assumes "berry" is the item ID
                // show_debug_message($"{pop_identifier_string} foraged a 'berry'.");
				global.lineage_food_stock = scr_get_item_stats()
            }

            // Check if task is complete (target depleted)
            if (_target_is_depleted) {
                show_debug_message($"Pop {pop_identifier_string} (ID: {id}) finished foraging: target {target_interaction_object_id} depleted or invalid.");
                
                scr_interaction_slot_release(target_interaction_object_id, id); // Release the slot
                
                // Calculate a "step away" position
                var _step_away_dist = irandom_range(30, 50);
                // For L/R slots, stepping directly "south" (increasing Y) from current pop position is usually fine.
                var _new_travel_x = x; 
                var _new_travel_y = y + _step_away_dist;

                // Clean up foraging-specific target info now, as it's moving to a generic point
                target_interaction_object_id = noone; 
                target_interaction_slot_index = -1; 
                target_interaction_type_tag = "";
                
                // Set pop to move to this new "waiting spot"
                travel_point_x = _new_travel_x;
                travel_point_y = _new_travel_y;
                
                state = PopState.COMMANDED; // Go to COMMANDED to execute the small move
                is_waiting = false;         // Not waiting yet, it's moving
                has_arrived = false;        // Needs to arrive at this new step-away spot
                
                // scr_pop_commanded will handle animation, speed, and transitioning to WAITING
                // (and setting depth = -y) upon arrival at this new travel_point.
                
                show_debug_message($"Pop {id} (foraging complete) stepping away to ({floor(travel_point_x)},{floor(travel_point_y)}) before waiting.");
                exit; // Exit script for this step, next step COMMANDED will take over
            }
        }
    } 
    // else if (target_interaction_type_tag == "some_other_task") { /* Handle other tasks */ }
    #endregion
	#region 2.2 Dropping off Load
		var total_items_in_inventory = 0;
		for (var i = 0; i < ds_list_size(inventory_items); i++) {
		    total_items_in_inventory += inventory_items[| i].quantity;
		}
		var hauling_threshold = 5; // Example: Haul if carrying 5 or more items

		if (total_items_in_inventory >= hauling_threshold) {
		    show_debug_message($"Pop {id} ({pop_name}) inventory has {total_items_in_inventory} items. Triggering HAULING.");
		    // Release current interaction slot from foraging
		    if (instance_exists(target_interaction_object_id) && _slot_index != -1) {
		        if (script_exists(scr_interaction_slot_release)) {
		            scr_interaction_slot_release(target_interaction_object_id, _slot_index, id);
		        }
		        _slot_index = -1; // Mark slot as released by this pop
		    }
		    target_interaction_object_id = noone; // Clear foraging target

		    state = PopState.HAULING;
		    target_object_id = noone; // Hauling script will find a new target (the hut)
		    exit; // Exit foraging script as state has changed
		}
	#endregion
}