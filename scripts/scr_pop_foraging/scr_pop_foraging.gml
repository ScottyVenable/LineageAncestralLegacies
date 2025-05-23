/// scr_pop_foraging.gml (or scr_pop_interaction_work.gml)

/// Purpose:
///   Handles the behavior for a pop that is tasked with an interaction
///   at a specific slot on a target object (e.g., foraging from a bush).
///   Manages movement to the slot, performing the interaction using correct
///   directional sprites, releasing the slot, and then stepping a short distance
///   away before transitioning to a commanded move to that spot (which then leads to WAITING).
///

/// Metadata:
///     Summary:       Move to slot, perform work, release slot, step away, then commanded to wait.
///     Usage:         Called by scr_pop_behavior when state is PopState.FORAGING (or a generic WORKING state).
///     Version:       1.4 - [Current Date] (Pop steps away from bush after foraging by setting a new commanded move)
///     Dependencies:  scr_interaction_slot_get_world_pos, scr_interaction_slot_release,
///                    scr_update_walk_sprite, scr_inventory_struct_add, PopState (enum),
///                    Instance variables: target_interaction_object_id, target_interaction_slot_index, etc.

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
            speed = pop.base_speed *1.3; // Movement speed towards slot
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
     // Keep pop in front while working
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
        depth = target_interaction_object_id.depth - 1;
		forage_timer += 1;
        if (forage_timer >= forage_rate) {
            forage_timer = 0; // Reset for next tick
            var _item_harvested_this_tick = false;
            var _target_is_depleted = false;

            // --- Modular Interaction with the target_interaction_object_id ---
            // This section now assumes the target object has:
            // - is_harvestable (boolean)
            // - resource_count (integer, e.g., how many berries/sticks are left)
            // - item_yield_enum (Item enum, e.g., Item.FOOD_RED_BERRY, Item.WOOD_STICK)
            // - yield_quantity_per_cycle (integer, e.g., 1, 2)
            // - spr_empty (sprite_index, sprite to show when depleted)

            if (instance_exists(target_interaction_object_id) && 
                variable_instance_exists(target_interaction_object_id, "is_harvestable") &&
                target_interaction_object_id.is_harvestable &&
                variable_instance_exists(target_interaction_object_id, "resource_count") &&    // Check for generic resource_count
                variable_instance_exists(target_interaction_object_id, "item_yield_enum") && // Check for item type to yield
                variable_instance_exists(target_interaction_object_id, "yield_quantity_per_cycle")) { // Check for yield quantity

                if (target_interaction_object_id.resource_count > 0) {
                    // Determine how many items to actually gather this cycle
                    var _items_to_gather_this_cycle = min(target_interaction_object_id.yield_quantity_per_cycle, target_interaction_object_id.resource_count);
                    
                    target_interaction_object_id.resource_count -= _items_to_gather_this_cycle;
                    _item_harvested_this_tick = true;
					
					var _item_enum_to_add = target_interaction_object_id.item_yield_enum; // Get item type from target

					// 'self' here refers to the obj_pop instance running this script
					if (!variable_instance_exists(id, "inventory_items")) {
					    inventory_items = ds_list_create(); 
					    show_debug_message($"Warning: Pop {id} inventory_items not found, created new list.");
					}

					show_debug_message($"Pop {id} ({pop_name}) gathered {_items_to_gather_this_cycle} of item enum {_item_enum_to_add}. Attempting to add to inventory.");

					var _items_not_added = scr_inventory_add_item(self.inventory_items, _item_enum_to_add, _items_to_gather_this_cycle);

					if (_items_not_added > 0) {
					    show_debug_message($"Pop {id} inventory full or issue, {_items_not_added} of item enum {_item_enum_to_add} dropped/lost.");
					    // TODO: Implement logic for dropping items on the ground if inventory is full
					    // This could involve creating a temporary item drop object at the pop's location.
					}
					
                    if (target_interaction_object_id.resource_count <= 0) { // Check if depleted
                        target_interaction_object_id.is_harvestable = false;
                        if (variable_instance_exists(target_interaction_object_id, "spr_empty") && // Ensure spr_empty exists
                            sprite_exists(target_interaction_object_id.spr_empty)) { 
                             target_interaction_object_id.sprite_index = target_interaction_object_id.spr_empty;
                        }
                        _target_is_depleted = true;
                        show_debug_message($"Target {target_interaction_object_id} depleted. Resource count: {target_interaction_object_id.resource_count}");
                    }
                } else { // resource_count is 0 or less
                    _target_is_depleted = true;
                    target_interaction_object_id.is_harvestable = false; // Ensure flag is set
                    show_debug_message($"Target {target_interaction_object_id} already depleted before attempt. Resource count: {target_interaction_object_id.resource_count}");
                }
            } else { // Target doesn't exist, isn't harvestable, or lacks necessary variables
                _target_is_depleted = true; 
                show_debug_message($"Pop {pop_identifier_string} (ID: {id}) found target {target_interaction_object_id} invalid or missing required foraging variables (is_harvestable, resource_count, item_yield_enum, yield_quantity_per_cycle).");
                // If the target object itself is gone, we can't really do much with it.
                // If it exists but is missing variables, it's a setup error for that object.
            }

            // Check if task is complete (target depleted or became invalid)
            if (_target_is_depleted) {
                var _pop_id_str_depletion = pop_identifier_string + " (ID:" + string(id) + ")"; // For logging
                show_debug_message("Pop " + _pop_id_str_depletion + " finished foraging: target " + string(target_interaction_object_id) + " depleted or invalid.");
                
                // Release the slot robustly
                var _slot_release_idx = asset_get_index("scr_interaction_slot_release");
                if (_slot_release_idx != -1 && script_exists(_slot_release_idx)) {
                    if (instance_exists(target_interaction_object_id)) { // Check instance exists before passing to script
                        script_execute(_slot_release_idx, target_interaction_object_id, id);
                    } else {
                         show_debug_message("Pop " + _pop_id_str_depletion + " target " + string(target_interaction_object_id) + " no longer exists. Cannot release slot formally.");
                    }
                } else {
                    show_debug_message("ERROR: scr_interaction_slot_release script not found! Pop " + _pop_id_str_depletion + " cannot release slot after depletion.");
                }

                // The pop was foraging, and the task ended because the resource was depleted.
                // It should try to find a new foraging task after stepping away.
                self.previous_state = PopState.FORAGING;
                // Clear the specific last target because it's gone.
                // The resume script will then know to search for a *new* target.
                self.last_foraged_target_id = noone;
                self.last_foraged_slot_index = -1;
                self.last_foraged_type_tag = "";
                
                // Calculate a "step away" position
                var _step_away_dist = irandom_range(30, 50);
                var _new_travel_x = x; 
                var _new_travel_y = y + _step_away_dist;

                // Clean up foraging-specific target info from current task variables
                target_interaction_object_id = noone; 
                target_interaction_slot_index = -1; 
                target_interaction_type_tag = "";
                
                // Set pop to move to this new "waiting spot"
                travel_point_x = _new_travel_x;
                travel_point_y = _new_travel_y;
                
                state = PopState.COMMANDED; // Go to COMMANDED to execute the small move
                is_waiting = false;         // Not waiting yet, it's moving
                has_arrived = false;        // Needs to arrive at this new step-away spot
                
                show_debug_message("Pop " + _pop_id_str_depletion + " (foraging complete due to depletion) setting previous_state=FORAGING, last_target_vars cleared. Stepping away to (" + string(floor(travel_point_x)) + "," + string(floor(travel_point_y)) + ") before resuming/idling.");
                exit; // Exit script for this step, next step COMMANDED will take over
            }
        }
    } 
    // else if (target_interaction_type_tag == "some_other_task") { /* Handle other tasks */ }
    #endregion

    // =========================================================================
    // 5. CHECK INVENTORY CAPACITY (Now the sole check for hauling)
    // =========================================================================
    #region 5.1 Check if Inventory Reaches Hauling Threshold
    var hauling_threshold = pop.base_max_items_carried; 
    var total_items_in_inventory = 0;
    // Ensure inventory_items list exists before trying to access it
    if (variable_instance_exists(id, "inventory_items") && ds_exists(inventory_items, ds_type_list)) {
        for (var i = 0; i < ds_list_size(inventory_items); i++) {
            var item_struct = inventory_items[| i];
            if (is_struct(item_struct) && variable_struct_exists(item_struct, "quantity")) {
                total_items_in_inventory += item_struct.quantity;
            }
        }
    }

    if (total_items_in_inventory >= hauling_threshold) {
        // This block executes if the pop's inventory has reached the threshold to start hauling.

        // 1. Store details of the current foraging task BEFORE releasing the slot or clearing target variables.
        // This information is crucial if the pop needs to resume a similar task later.
        self.previous_state = PopState.FORAGING; // Record that the pop was foraging.
        self.last_foraged_target_id = target_interaction_object_id; // Store the ID of the object being foraged.
        self.last_foraged_slot_index = target_interaction_slot_index; // Store the specific slot index used.
        self.last_foraged_type_tag = target_interaction_type_tag;   // Store the type of interaction (e.g., "forage_left").
        
        // For debugging: create a concise identifier string for the pop.
        var _pop_id_str = pop_identifier_string + " (ID:" + string(id) + ")";
        
        // Log detailed information about the transition.
        // Note: Using string concatenation for compatibility, as GMS 2.3+ f-strings might not be desired here.
        show_debug_message("Pop " + _pop_id_str + " inventory (" + string(total_items_in_inventory) + "/" + string(hauling_threshold) + 
                           ") met hauling threshold. Last Foraged Target: " + 
                           (instance_exists(self.last_foraged_target_id) ? object_get_name(self.last_foraged_target_id.object_index) + "(" + string(self.last_foraged_target_id) + ")" : "noone") + 
                           ", Slot: " + string(self.last_foraged_slot_index) + ". Transitioning to HAULING.");

        // 2. Release the interaction slot the pop was using at the foraging target.
        // It's important to free up the slot so other pops can use it.
        if (instance_exists(target_interaction_object_id) && target_interaction_slot_index != -1) {
             var _scr_slot_release_idx = asset_get_index("scr_interaction_slot_release"); // Get the script asset for releasing slots.
             if (_scr_slot_release_idx != -1 && script_exists(_scr_slot_release_idx)) {
                // Execute the slot release script, passing the target object and the pop's ID.
                script_execute(_scr_slot_release_idx, target_interaction_object_id, id); 
             } else {
                // Log an error if the slot release script cannot be found.
                show_debug_message("ERROR: scr_interaction_slot_release script not found! Pop " + _pop_id_str + " cannot release slot before hauling.");
             }
        }

        // 3. Clean up foraging-specific variables from the pop's instance.
        // Since the pop is now hauling, it no longer has a foraging target.
        target_interaction_object_id = noone; // Clear the foraging target ID.
        target_interaction_slot_index = -1;   // Reset the slot index.
        target_interaction_type_tag = "";     // Clear the interaction type tag.
        has_arrived = false; // Reset 'has_arrived' as the pop will need to move for hauling.

        // 4. Set the pop's state to HAULING.
        // The main behavior script (scr_pop_behavior) will then call scr_pop_hauling in the next step.
        state = PopState.HAULING;
        
        // Exit this script immediately since the state has changed.
        // Further logic in this script is for foraging, which is no longer relevant.
        exit; 
    }
    #endregion
}