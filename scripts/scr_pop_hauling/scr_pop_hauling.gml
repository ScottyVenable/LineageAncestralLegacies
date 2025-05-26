/// scr_pop_hauling.gml
///
/// Purpose:
///   Handles the "hauling" behavior state for a pop instance. In this state,
///   the pop attempts to find a resource to pick up, moves to it, collects it
///   (if it has capacity), then finds a designated drop-off point (e.g., a
///   stockpile or specific building) and moves to deposit the resource.
///
/// Metadata:
///   Summary: Manages pop behavior for picking up and hauling resources.
///   Usage: Called from obj_pop's state machine (Step Event) when current_state is EntityState.HAULING.
///   Parameters:
///     target_pop : instance_id — The pop instance executing the hauling behavior.
///   Returns: void (modifies target_pop directly)
///   Tags: [behavior][pop][resource][hauling][ai]
///   Version: 1.2 — 2025-07-28 (Refactored to use entity_data)
///   Dependencies: EntityState enum, scr_find_nearest_resource, scr_find_nearest_stockpile,
///                 instance_exists, point_distance, pathfinding (optional).
///   Created: (Assumed prior to 2023)
///   Modified: 2025-07-28

function scr_pop_hauling(target_pop) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    var self = target_pop; // Reference to the pop instance
    var _room_speed = room_speed;
    var TILE_SIZE = 16; // Should be a global or game setting
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    if (!instance_exists(self)) {
        show_debug_message("ERROR: scr_pop_hauling() — Invalid target_pop instance.");
        return;
    }
    if (!variable_instance_exists(self, "current_state") || self.current_state != EntityState.HAULING) {
        // show_debug_message("INFO: scr_pop_hauling() — Pop " + string(self) + " not in HAULING state.");
        return;
    }
    // Ensure necessary data structures from entity_data are present
    if (!variable_instance_exists(self, "stats") || !is_struct(self.stats)) {
        show_debug_message("ERROR: scr_pop_hauling() - Pop " + string(self) + " is missing 'stats' struct.");
        scr_pop_resume_previous_or_idle(self); // Attempt to recover
        return;
    }
    if (!variable_instance_exists(self, "behavior_settings") || !is_struct(self.behavior_settings)) {
        show_debug_message("ERROR: scr_pop_hauling() - Pop " + string(self) + " is missing 'behavior_settings' struct.");
        scr_pop_resume_previous_or_idle(self); // Attempt to recover
        return;
    }
    if (!variable_instance_exists(self, "inventory") || !is_array(self.inventory)) {
        show_debug_message("ERROR: scr_pop_hauling() - Pop " + string(self) + " is missing 'inventory' array.");
        scr_pop_resume_previous_or_idle(self); // Attempt to recover
        return;
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS (from Pop's Data Profile)
    // =========================================================================
    #region 2.1 Behavior-Specific Parameters
    // var move_speed = self.stats.base_move_speed; // OLD: base_move_speed is not used.
    // Hauling speed is a percentage of the pop's walk_speed.
    // Ensure walk_speed exists in stats; if not, use a fallback to prevent errors.
    // LEARNING POINT: Accessing nested struct variables like 'self.stats.walk_speed' can lead to errors
    // if 'self.stats' itself doesn't exist, or if 'walk_speed' isn't a member of 'stats'.
    // It's good practice to check for the existence of each level of the structure.
    var _base_walk_speed = 1.0; // Default fallback walk_speed
    if (variable_instance_exists(self, "stats")) { // Check if the 'stats' struct exists on 'self'
        if (variable_struct_exists(self.stats, "walk_speed")) { // Check if 'walk_speed' exists within 'stats'
            _base_walk_speed = self.stats.walk_speed;
        } else {
            // Log a warning if 'walk_speed' is missing from 'stats', helps in debugging.
            show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.stats.walk_speed not found. Using fallback: {_base_walk_speed}");
        }
    } else {
        // Log a warning if the entire 'stats' struct is missing, which is a more significant issue.
        show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.stats struct not found. Using fallback walk_speed: {_base_walk_speed}");
    }
    var move_speed = _base_walk_speed * 0.75; // Hauling speed is 75% of walk_speed.

    // var carry_capacity_kg = self.stats.carry_capacity_kg; // OLD: Direct access, less safe.
    // Safely access carry_capacity_kg from stats, with a fallback.
    var carry_capacity_kg = 10; // Default fallback carry capacity
    if (variable_instance_exists(self, "stats")) {
        if (variable_struct_exists(self.stats, "carry_capacity_kg")) {
            carry_capacity_kg = self.stats.carry_capacity_kg;
        } else {
            show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.stats.carry_capacity_kg not found. Using fallback: {carry_capacity_kg}kg");
        }
    } else {
        show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.stats struct not found. Using fallback carry_capacity_kg: {carry_capacity_kg}kg");
    }
    
    // Threshold for how "full" inventory needs to be (percentage) before seeking drop-off.
    // var hauling_fullness_threshold_percent = self.behavior_settings.hauling_fullness_threshold_percent; // OLD: Direct access
    // Safely access hauling_fullness_threshold_percent from behavior_settings, with a fallback.
    var hauling_fullness_threshold_percent = 75; // Default to 75% if not set
    if (variable_instance_exists(self, "behavior_settings")) {
        if (variable_struct_exists(self.behavior_settings, "hauling_fullness_threshold_percent")) {
            hauling_fullness_threshold_percent = self.behavior_settings.hauling_fullness_threshold_percent;
        } else {
            show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.behavior_settings.hauling_fullness_threshold_percent not found. Using fallback: {hauling_fullness_threshold_percent}%");
        }
    } else {
        show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.behavior_settings struct not found. Using fallback hauling_fullness_threshold_percent: {hauling_fullness_threshold_percent}%");
    }

    // Calculate actual weight threshold based on percentage of carry capacity.
    var hauling_threshold_kg = carry_capacity_kg * (hauling_fullness_threshold_percent / 100);
    // var interaction_distance = self.behavior_settings.interaction_distance_pixels; // Distance to interact with items/stockpiles // OLD: Direct access
    // Safely access interaction_distance_pixels from behavior_settings, with a fallback.
    var interaction_distance = TILE_SIZE * 0.75; // Default interaction distance
    if (variable_instance_exists(self, "behavior_settings")) {
        if (variable_struct_exists(self.behavior_settings, "interaction_distance_pixels")) {
            var _setting_dist = self.behavior_settings.interaction_distance_pixels;
            if (is_real(_setting_dist) && _setting_dist > 0) {
                interaction_distance = _setting_dist;
            } else {
                show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.behavior_settings.interaction_distance_pixels is invalid ({_setting_dist}). Using fallback: {interaction_distance}");
            }
        } else {
            show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.behavior_settings.interaction_distance_pixels not found. Using fallback: {interaction_distance}");
        }
    } else {
        show_debug_message($"WARNING (scr_pop_hauling for Pop {self.id}): self.behavior_settings struct not found. Using fallback interaction_distance: {interaction_distance}");
    }
    // if (!is_real(interaction_distance) || interaction_distance <= 0) interaction_distance = TILE_SIZE * 0.75; // Default if not set // Covered by above

    // Resource types the pop is allowed to haul (can be specific or general)
    // Example: ["wood", "stone"], or a broader category like "any_raw_material"
    // For this example, we assume it can haul any item it finds via scr_find_nearest_item_for_hauling
    // var haulable_resource_types = self.behavior_settings.haulable_resource_types; // Array of item_id strings
    #endregion

    // =========================================================================
    // 3. STATE LOGIC (Sub-states: FIND_ITEM, MOVE_TO_ITEM, COLLECT_ITEM, FIND_DROPOFF, MOVE_TO_DROPOFF, DEPOSIT_ITEM)
    // =========================================================================
    // Initialize hauling sub-state if not present
    if (!variable_instance_exists(self, "hauling_sub_state")) {
        self.hauling_sub_state = "FIND_ITEM";
        self.target_item_instance = noone;
        self.target_dropoff_instance = noone;
        self.state_timer = 0; // General purpose timer for actions within sub-states
        // show_debug_message("Pop " + string(self) + " entering HAULING: FIND_ITEM");
    }

    // --- Calculate current inventory weight ---
    var current_inventory_weight = 0;
    for (var i = 0; i < array_length(self.inventory); i++) {
        var item_entry = self.inventory[i];
        if (is_struct(item_entry) && variable_struct_exists(item_entry, "item_data") && variable_struct_exists(item_entry.item_data, "weight_kg")) {
            current_inventory_weight += item_entry.quantity * item_entry.item_data.weight_kg;
        }
    }
    self.current_inventory_weight_kg = current_inventory_weight; // Update for UI or other systems

    // --- Hauling State Machine ---
    switch (self.hauling_sub_state) {
        //---------------------------------------------------------------------
        case "FIND_ITEM":
            // If inventory is already full enough, skip finding more items and go to drop-off.
            if (current_inventory_weight >= hauling_threshold_kg) {
                self.hauling_sub_state = "FIND_DROPOFF";
                self.target_item_instance = noone; // Clear previous item target
                // show_debug_message("Pop " + string(self) + " inventory full enough (" + string(current_inventory_weight) + "kg / " + string(hauling_threshold_kg) + "kg). Switching to FIND_DROPOFF.");
                break; // Re-evaluate switch in the same frame
            }

            // Try to find a nearby item that needs hauling.
            // scr_find_nearest_item_for_hauling should return an instance_id or noone.
            // It might consider item types, if they are not already in a stockpile, etc.
            self.target_item_instance = scr_find_nearest_item_for_hauling(self.x, self.y, self, undefined); // `undefined` for any type for now

            if (instance_exists(self.target_item_instance)) {
                self.hauling_sub_state = "MOVE_TO_ITEM";
                // show_debug_message("Pop " + string(self) + " found item " + string(self.target_item_instance) + ". Switching to MOVE_TO_ITEM.");
            } else {
                // No items to haul found. What to do? 
                // Option 1: Wait a bit and try again.
                // Option 2: Switch to a different state (e.g., IDLE or WANDERING).
                // show_debug_message("Pop " + string(self) + " found no items to haul. Switching to IDLE temporarily.");
                scr_pop_resume_previous_or_idle(self); // Go idle or to previous task
                // Or, set a timer to retry FIND_ITEM after a delay:
                // self.state_timer = 2 * _room_speed; // Wait 2 seconds
                // self.hauling_sub_state = "WAIT_BEFORE_RETRY_FIND_ITEM";
            }
            break;

        //---------------------------------------------------------------------
        // case "WAIT_BEFORE_RETRY_FIND_ITEM":
        //     self.state_timer--;
        //     if (self.state_timer <= 0) {
        //         self.hauling_sub_state = "FIND_ITEM";
        //     }
        //     break;

        //---------------------------------------------------------------------
        case "MOVE_TO_ITEM":
            if (!instance_exists(self.target_item_instance)) {
                // Target item disappeared (e.g., picked up by someone else).
                // show_debug_message("Pop " + string(self) + " target item no longer exists. Returning to FIND_ITEM.");
                self.hauling_sub_state = "FIND_ITEM";
                // Clear sprite and speed as we are no longer moving
                self.speed = 0;
                // Use spr_idle from stats, falling back to spr_pop_man_idle if not defined or invalid.
                var _default_idle_sprite_target_gone = spr_pop_man_idle; // Fallback sprite
                var _stat_idle_sprite_target_gone = (variable_instance_exists(self, "stats") && variable_struct_exists(self.stats, "spr_idle")) ? self.stats.spr_idle : _default_idle_sprite_target_gone;
                self.sprite_index = get_sprite_asset_safely(_stat_idle_sprite_target_gone, _default_idle_sprite_target_gone);
                self.image_speed = 1.0;
                break;
            }

            var _dist_to_item = point_distance(self.x, self.y, self.target_item_instance.x, self.target_item_instance.y);

            if (_dist_to_item <= interaction_distance) {
                // Reached the item.
                self.hauling_sub_state = "COLLECT_ITEM";
                // show_debug_message("Pop " + string(self) + " reached item " + string(self.target_item_instance) + ". Switching to COLLECT_ITEM.");
            } else {
                // Move towards the item.
                // Simple direct movement; replace with pathfinding if needed.
                var _dir = point_direction(self.x, self.y, self.target_item_instance.x, self.target_item_instance.y);
                self.x += lengthdir_x(min(move_speed, _dist_to_item), _dir);
                self.y += lengthdir_y(min(move_speed, _dist_to_item), _dir);
                // Basic sprite flipping (assuming sprites face right by default)
                if (self.x != self.xprevious) {
                     // self.image_xscale = sign(self.x - self.xprevious); // OLD way, direct scale
                     // New way: use scr_update_walk_sprite which handles direction and animation
                     scr_update_walk_sprite(self); // Pass 'self' to update its own sprite based on movement
                }
                self.image_speed = 1.0; // Standard animation speed for walking
            }
            break;

        //---------------------------------------------------------------------
        case "COLLECT_ITEM":
            if (!instance_exists(self.target_item_instance)) {
                self.hauling_sub_state = "FIND_ITEM"; // Item gone
                // Clear sprite and speed as we are no longer interacting
                self.speed = 0;
                // Use spr_idle from stats, falling back to spr_pop_man_idle if not defined or invalid.
                var _default_idle_sprite_collect_gone = spr_pop_man_idle; // Fallback sprite
                var _stat_idle_sprite_collect_gone = (variable_instance_exists(self, "stats") && variable_struct_exists(self.stats, "spr_idle")) ? self.stats.spr_idle : _default_idle_sprite_collect_gone;
                self.sprite_index = get_sprite_asset_safely(_stat_idle_sprite_collect_gone, _default_idle_sprite_collect_gone);
                self.image_speed = 1.0;
                break;
            }

            // Attempt to pick up the item.
            // This requires the item instance to have item_id, quantity, and item_data (with weight_kg).
            // And the pop to have an scr_inventory_add_item function.
            if (variable_instance_exists(self.target_item_instance, "item_id") &&
                variable_instance_exists(self.target_item_instance, "quantity") &&
                variable_instance_exists(self.target_item_instance, "item_data")) {

                var item_to_collect = self.target_item_instance;
                var weight_of_this_item = item_to_collect.quantity * item_to_collect.item_data.weight_kg;

                if (current_inventory_weight + weight_of_this_item <= carry_capacity_kg) {
                    // Can carry it. Add to inventory.
                    var success = scr_inventory_add_item(self, item_to_collect.item_id, item_to_collect.quantity, item_to_collect.item_data);
                    if (success) {
                        // show_debug_message("Pop " + string(self) + " collected " + string(item_to_collect.quantity) + "x " + item_to_collect.item_id + ".");
                        instance_destroy(item_to_collect); // Remove the item from the world
                        self.target_item_instance = noone;
                        // Recalculate current weight for next decision
                        current_inventory_weight += weight_of_this_item;
                        self.current_inventory_weight_kg = current_inventory_weight;
                        
                        // Decide next step: find more items or find drop-off?
                        if (current_inventory_weight >= hauling_threshold_kg) {
                            self.hauling_sub_state = "FIND_DROPOFF";
                            // show_debug_message("Pop " + string(self) + " inventory full enough after pickup. Switching to FIND_DROPOFF.");
                        } else {
                            self.hauling_sub_state = "FIND_ITEM"; // Look for more items
                            // show_debug_message("Pop " + string(self) + " looking for more items.");
                        }
                    } else {
                        // Failed to add to inventory (should not happen if weight check passed, but maybe other reasons)
                        // show_debug_message("Pop " + string(self) + " failed to add item " + item_to_collect.item_id + " to inventory. Returning to FIND_ITEM.");
                        self.hauling_sub_state = "FIND_ITEM";
                    }
                } else {
                    // Too heavy to pick up this specific item with current load.
                    // show_debug_message("Pop " + string(self) + " cannot carry item " + item_to_collect.item_id + " (too heavy). Switching to FIND_DROPOFF if carrying anything, else FIND_ITEM (for lighter items).");
                    if (current_inventory_weight > 0) {
                        self.hauling_sub_state = "FIND_DROPOFF"; // Go drop off what it has
                    } else {
                        // Can't even carry this single item, and inventory is empty. Maybe it's just too heavy for this pop.
                        // Or, the item is bugged (e.g. massive weight).
                        // For now, just try to find other (potentially lighter) items.
                        self.target_item_instance = noone; // Forget this heavy item
                        self.hauling_sub_state = "FIND_ITEM"; 
                    }
                }
            } else {
                // Target item is not a valid collectible item (missing properties).
                // show_debug_message("Pop " + string(self) + " target item " + string(self.target_item_instance) + " is not a valid collectible. Returning to FIND_ITEM.");
                self.hauling_sub_state = "FIND_ITEM";
            }
            break;

        //---------------------------------------------------------------------
        case "FIND_DROPOFF":
            // If inventory is empty, something went wrong, or it just dropped off.
            // Go back to finding items.
            if (current_inventory_weight <= 0 && array_length(self.inventory) == 0) {
                // show_debug_message("Pop " + string(self) + " inventory empty. Switching to FIND_ITEM.");
                self.hauling_sub_state = "FIND_ITEM";
                break;
            }

            // Find the nearest suitable drop-off point (e.g., a stockpile object).
            // scr_find_nearest_stockpile should return an instance_id or noone.
            // It might also consider if the stockpile can accept the items the pop is carrying.
            self.target_dropoff_instance = scr_find_nearest_stockpile(self.x, self.y, self, self.inventory); 

            if (instance_exists(self.target_dropoff_instance)) {
                self.hauling_sub_state = "MOVE_TO_DROPOFF";
                // show_debug_message("Pop " + string(self) + " found dropoff " + string(self.target_dropoff_instance) + ". Switching to MOVE_TO_DROPOFF.");
            } else {
                // No drop-off point found. This is problematic.
                // Options: Wait and retry, or switch to IDLE and hope one gets built.
                // show_debug_message("Pop " + string(self) + " found no dropoff point! Switching to IDLE temporarily.");
                scr_pop_resume_previous_or_idle(self); // Go idle or to previous task
                // Or, set a timer to retry FIND_DROPOFF after a delay:
                // self.state_timer = 5 * _room_speed; // Wait 5 seconds
                // self.hauling_sub_state = "WAIT_BEFORE_RETRY_FIND_DROPOFF";
            }
            break;

        //---------------------------------------------------------------------
        // case "WAIT_BEFORE_RETRY_FIND_DROPOFF":
        //     self.state_timer--;
        //     if (self.state_timer <= 0) {
        //         self.hauling_sub_state = "FIND_DROPOFF";
        //     }
        //     break;

        //---------------------------------------------------------------------
        case "MOVE_TO_DROPOFF":
            if (!instance_exists(self.target_dropoff_instance)) {
                // Target dropoff disappeared (e.g., destroyed).
                // show_debug_message("Pop " + string(self) + " target dropoff no longer exists. Returning to FIND_DROPOFF.");
                self.hauling_sub_state = "FIND_DROPOFF";
                // Clear sprite and speed
                self.speed = 0;
                // Use spr_idle from stats, falling back to spr_pop_man_idle if not defined or invalid.
                var _default_idle_sprite_dropoff_gone = spr_pop_man_idle; // Fallback sprite
                var _stat_idle_sprite_dropoff_gone = (variable_instance_exists(self, "stats") && variable_struct_exists(self.stats, "spr_idle")) ? self.stats.spr_idle : _default_idle_sprite_dropoff_gone;
                self.sprite_index = get_sprite_asset_safely(_stat_idle_sprite_dropoff_gone, _default_idle_sprite_dropoff_gone);
                self.image_speed = 1.0;
                break;
            }

            var _dist_to_dropoff = point_distance(self.x, self.y, self.target_dropoff_instance.x, self.target_dropoff_instance.y);

            if (_dist_to_dropoff <= interaction_distance) {
                // Reached the drop-off point.
                self.hauling_sub_state = "DEPOSIT_ITEM";
                // show_debug_message("Pop " + string(self) + " reached dropoff " + string(self.target_dropoff_instance) + ". Switching to DEPOSIT_ITEM.");
            } else {
                // Move towards the drop-off point.
                var _dir = point_direction(self.x, self.y, self.target_dropoff_instance.x, self.target_dropoff_instance.y);
                self.x += lengthdir_x(min(move_speed, _dist_to_dropoff), _dir);
                self.y += lengthdir_y(min(move_speed, _dist_to_dropoff), _dir);
                // Basic sprite flipping
                if (self.x != self.xprevious) {
                     // self.image_xscale = sign(self.x - self.xprevious); // OLD way
                     scr_update_walk_sprite(self); // New way
                }
                self.image_speed = 1.0; // Standard animation speed for walking
            }
            break;

        //---------------------------------------------------------------------
        case "DEPOSIT_ITEM":
            if (!instance_exists(self.target_dropoff_instance)) {
                self.hauling_sub_state = "FIND_DROPOFF"; // Dropoff gone
                break;
            }

            // Attempt to deposit items into the stockpile.
            // This requires the stockpile to have a method like `accept_item(item_id, quantity, item_data)`
            // or for this script to directly manage global item stocks if stockpiles are abstract.
            // For this example, assume a function on the stockpile or a global function.
            
            var items_deposited_this_cycle = false;
            if (variable_instance_exists(self.target_dropoff_instance, "inventory_target_struct_name")) {
                // This stockpile is a controller that manages a global inventory (e.g., global.lineage_main_storage)
                var _target_inventory_name = self.target_dropoff_instance.inventory_target_struct_name;
                
                // Iterate through pop's inventory and try to add to the target global inventory
                for (var i = array_length(self.inventory) - 1; i >= 0; i--) {
                    var item_entry = self.inventory[i];
                    // Call a global/controller script to handle adding to the target storage
                    // This script would need to exist and handle the logic (e.g. scr_add_item_to_global_storage)
                    var deposited_successfully = scr_stockpile_deposit_item(self.target_dropoff_instance, item_entry.item_id, item_entry.quantity, item_entry.item_data);
                    
                    if (deposited_successfully) {
                        // Construct the message for the UI
                        var _display_name = (variable_instance_exists(self, "display_name")) ? self.display_name : "Pop";
                        var _item_name = (variable_struct_exists(item_entry.item_data, "display_name")) ? item_entry.item_data.display_name : item_entry.item_id;
                        var _stockpile_name = instance_exists(self.target_dropoff_instance) ? object_get_name(self.target_dropoff_instance.object_index) : "stockpile";
                        var _message = $"{_display_name} deposited {item_entry.quantity}x {_item_name} to {_stockpile_name}.";
                        // Call the UI display function with the correct number of arguments
                        scr_ui_showDropoffText(_message, 3); // Display for 3 seconds

                        // show_debug_message("Pop " + string(self) + " deposited " + string(item_entry.quantity) + "x " + item_entry.item_id + " to " + _target_inventory_name + ".");
                        scr_inventory_remove_item(self, item_entry.item_id, item_entry.quantity); // Remove from pop's inventory
                        items_deposited_this_cycle = true;
                    } else {
                        // show_debug_message("Pop " + string(self) + " failed to deposit " + item_entry.item_id + " to " + _target_inventory_name + ". Stockpile might be full for this item type.");
                    }
                }
            } else {
                // Fallback or error: stockpile doesn't have the expected variable to identify its inventory.
                // show_debug_message("ERROR: Pop " + string(self) + " - Target stockpile " + string(self.target_dropoff_instance) + " does not have 'inventory_target_struct_name'. Cannot deposit.");
            }

            if (items_deposited_this_cycle) {
                 // After depositing, recalculate weight and decide next step.
                current_inventory_weight = 0; // Will be recalculated at the start of the script
                for (var i = 0; i < array_length(self.inventory); i++) {
                    var item_entry = self.inventory[i];
                    if (is_struct(item_entry) && variable_struct_exists(item_entry, "item_data") && variable_struct_exists(item_entry.item_data, "weight_kg")) {
                        current_inventory_weight += item_entry.quantity * item_entry.item_data.weight_kg;
                    }
                }
                self.current_inventory_weight_kg = current_inventory_weight;
            }
            
            // After attempting deposit, always go back to FIND_ITEM to re-evaluate.
            // This handles cases where not all items could be deposited (e.g., stockpile full for some types).
            self.hauling_sub_state = "FIND_ITEM";
            self.target_dropoff_instance = noone;
            // show_debug_message("Pop " + string(self) + " finished deposit attempt. Returning to FIND_ITEM.");
            break;

        //---------------------------------------------------------------------
        default:
            // Unknown sub-state, reset to FIND_ITEM to be safe.
            // show_debug_message("Pop " + string(self) + " in unknown hauling sub-state: " + string(self.hauling_sub_state) + ". Resetting to FIND_ITEM.");
            self.hauling_sub_state = "FIND_ITEM";
            break;
    }
    #endregion

    // =========================================================================
    // 4. MOVEMENT & ANIMATION (Handled within sub-states for this behavior)
    // =========================================================================
    // #region 4.1 Sprite and Animation
    // Basic sprite updates are handled in MOVE_TO_ITEM and MOVE_TO_DROPOFF.
    // More complex animation (e.g., carrying animation) would go here or be part of a dedicated animation controller.
    // if (current_inventory_weight > 0 && variable_instance_exists(self, "spr_carry_walk_left")) {
    //     // Example: Use carrying sprites if holding items
    //     if (self.x > self.xprevious) self.sprite_index = self.spr_carry_walk_right;
    //     else if (self.x < self.xprevious) self.sprite_index = self.spr_carry_walk_left;
    // } else if (variable_instance_exists(self, "spr_walk_left")){
    //     // Standard walking sprites if not carrying or no specific carry sprites
    //     if (self.x > self.xprevious) self.sprite_index = self.spr_walk_right;
    //     else if (self.x < self.xprevious) self.sprite_index = self.spr_walk_left;
    // }
    // #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN (Handled by instance state or not applicable here)
    // =========================================================================
    // No explicit return. Modifies instance state directly.
}