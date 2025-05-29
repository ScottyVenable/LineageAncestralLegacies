/// scr_inventory_functions.gml
///
/// Purpose: Contains functions for managing pop and container inventories.
///
/// Metadata:
///   Summary:       Inventory manipulation utilities.
///   Tags:          [inventory][items][utility][data_management]
///   Version:       1.0 - [Current Date]
///   Dependencies:  Item enum (scr_items.gml), get_item_data() (scr_items.gml)

// ============================================================================
// FUNCTION: scr_inventory_add_item
// ============================================================================
/// @function scr_inventory_add_item(target_inventory_list, item_to_add_enum, quantity_to_add)
/// @description Adds a specified quantity of an item to a target inventory list (ds_list of structs).
///              Handles stacking and respects max_stack size.
/// @param {Id.DsList} target_inventory_list The ds_list representing the inventory.
/// @param {enum.Item} item_to_add_enum      The enum ID of the item to add.
/// @param {real}      quantity_to_add     The number of items to attempt to add.
/// @returns {real} The number of items that could NOT be added (e.g., due to full stacks or future capacity limits).
function scr_inventory_add_item(target_inventory_list, item_to_add_enum, quantity_to_add) {
    if (quantity_to_add <= 0) {
        return 0; // Nothing to add
    }
    // Ensure target_inventory_list is a valid ds_list
    // LEARNING POINT: Always validate ds_list existence and type before operating on it.
    if (!ds_exists(target_inventory_list, ds_type_list)) {
        show_debug_message("Error (scr_inventory_add_item): Invalid or non-list target_inventory_list provided.");
        return quantity_to_add; // Cannot add if the list itself is invalid
    }

    // Ensure get_item_data script exists before calling
    if (!script_exists(get_item_data)) {
        show_debug_message_once("ERROR (scr_inventory_add_item): get_item_data script missing!");
        return quantity_to_add; // Cannot proceed without item data
    }
    var item_base_data = get_item_data(item_to_add_enum);
    if (item_base_data == undefined) {
        show_debug_message($"Error (scr_inventory_add_item): Unknown item enum: {item_to_add_enum}. Cannot add.");
        return quantity_to_add; // Cannot add
    }

    // Determine max stack size from item_base_data, default to 1 if not specified.
    // LEARNING POINT: Using variable_struct_exists provides a safe way to access optional struct members.
    var max_stack_size = (variable_struct_exists(item_base_data, "max_stack")) ? item_base_data.max_stack : 1;
    // var item_weight = (variable_struct_exists(item_base_data, "weight_per_unit")) ? item_base_data.weight_per_unit : 0; // Weight check is handled by caller (e.g. scr_pop_hauling)
    var items_remaining_to_add = quantity_to_add;

    // --- Stage 1: Try to stack with existing items of the same type ---
    if (max_stack_size > 1) { // Only try to stack if the item is stackable
        for (var i = 0; i < ds_list_size(target_inventory_list); i++) {
            var existing_item_stack_struct = target_inventory_list[| i];
            
            // Check if it's the same item type and has space
            // LEARNING POINT: Structs in ds_lists must be checked for validity and member existence.
            if (is_struct(existing_item_stack_struct) && 
                variable_struct_exists(existing_item_stack_struct, "item_id_enum") &&
                existing_item_stack_struct.item_id_enum == item_to_add_enum &&
                variable_struct_exists(existing_item_stack_struct, "quantity") &&
                existing_item_stack_struct.quantity < max_stack_size) {
                
                var space_in_stack = max_stack_size - existing_item_stack_struct.quantity;
                var amount_to_actually_stack = min(items_remaining_to_add, space_in_stack);
                
                if (amount_to_actually_stack > 0) {
                    existing_item_stack_struct.quantity += amount_to_actually_stack;
                    items_remaining_to_add -= amount_to_actually_stack;
                    // Optional: More detailed debug message if needed
                    // show_debug_message($"Stacked {amount_to_actually_stack} of {item_base_data.name}. New stack size: {existing_item_stack_struct.quantity}");
                }
            }
            if (items_remaining_to_add <= 0) {
                break; // All items have been added
            }
        }
    }

    // --- Stage 2: If items still remain, create new stacks ---
    while (items_remaining_to_add > 0) {
        // TODO: Add a check for inventory slot capacity if the inventory has a maximum number of unique stacks/slots.
        // For now, we assume it can add new stacks indefinitely as long as weight allows (checked by caller).

        var amount_for_new_stack = min(items_remaining_to_add, max_stack_size);
        
        var new_item_stack_struct = {
            item_id_enum: item_to_add_enum,
            quantity: amount_for_new_stack
            // item_data: item_base_data // Store a copy of base data if needed for quick access, though can increase memory.
                                       // For hauling, weight is checked before pickup, so direct item_data might not be needed in each stack.
        };
        // For items with durability, like tools (not berries)
        if (variable_struct_exists(item_base_data, "durability_max")) {
            new_item_stack_struct.durability = item_base_data.durability_max;
        }

        ds_list_add(target_inventory_list, new_item_stack_struct);
        items_remaining_to_add -= amount_for_new_stack;
        // Optional: More detailed debug message
        // show_debug_message($"Created new stack of {item_base_data.name} with quantity {amount_for_new_stack}.");
    }
    
    if (items_remaining_to_add > 0) {
        // This case implies an issue not caught above, or a future constraint like max inventory slots.
        show_debug_message($"Warning (scr_inventory_add_item): Could not add {items_remaining_to_add} of item enum {item_to_add_enum} (was {item_base_data.name}). Inventory might be full or other constraints not yet implemented (e.g. max slots).");
    }
    return items_remaining_to_add; // Return how many couldn't be added
}

// ============================================================================
// FUNCTION: scr_inventory_remove_item_from_list
// ============================================================================
/// @function scr_inventory_remove_item_from_list(target_inventory_list, item_to_remove_enum, quantity_to_remove)
/// @description Removes a specified quantity of an item from a target inventory list (ds_list of structs).
///              Removes from stacks, prioritizing stacks with smaller quantities first if multiple exist,
///              or from the end of the list.
/// @param {Id.DsList} target_inventory_list The ds_list representing the inventory.
/// @param {enum.Item} item_to_remove_enum   The enum ID of the item to remove.
/// @param {real}      quantity_to_remove  The number of items to attempt to remove.
/// @returns {real} The number of items that were successfully removed.
function scr_inventory_remove_item_from_list(target_inventory_list, item_to_remove_enum, quantity_to_remove) {
    if (quantity_to_remove <= 0) {
        return 0; // Nothing to remove
    }
    if (!ds_exists(target_inventory_list, ds_type_list)) {
        show_debug_message("Error (scr_inventory_remove_item_from_list): Invalid target_inventory_list provided.");
        return 0; // Cannot remove
    }

    var items_actually_removed = 0;
    var items_still_to_remove = quantity_to_remove;

    // Iterate backwards through the list to safely remove empty stacks
    for (var i = ds_list_size(target_inventory_list) - 1; i >= 0; i--) {
        var current_stack_struct = target_inventory_list[| i];

        if (is_struct(current_stack_struct) && 
            variable_struct_exists(current_stack_struct, "item_id_enum") &&
            current_stack_struct.item_id_enum == item_to_remove_enum &&
            variable_struct_exists(current_stack_struct, "quantity")) {
            
            var amount_to_remove_from_this_stack = min(items_still_to_remove, current_stack_struct.quantity);
            
            if (amount_to_remove_from_this_stack > 0) {
                current_stack_struct.quantity -= amount_to_remove_from_this_stack;
                items_actually_removed += amount_to_remove_from_this_stack;
                items_still_to_remove -= amount_to_remove_from_this_stack;

                // If stack becomes empty, remove it from the list
                if (current_stack_struct.quantity <= 0) {
                    ds_list_delete(target_inventory_list, i);
                    // Note: No need to free the struct itself if it was created inline, GC handles it.
                    // If it was a ds_map or another ds_type, it would need explicit destruction.
                }
            }
        }
        if (items_still_to_remove <= 0) {
            break; // All requested items have been removed
        }
    }

    if (items_still_to_remove > 0) {
        // This means not enough items of the specified type were found.
        // Ensure get_item_data script exists before calling
        var _item_name_for_debug = "Unknown Item";
        if (script_exists(get_item_data)) {
            var item_base_data_debug = get_item_data(item_to_remove_enum);
            if (item_base_data_debug != undefined && variable_struct_exists(item_base_data_debug, "name")) {
                 _item_name_for_debug = item_base_data_debug.name;
            } else {
                _item_name_for_debug = $"Enum({item_to_remove_enum})";
            }
        } else {
             _item_name_for_debug = $"Enum({item_to_remove_enum}) (get_item_data missing)";
        }
        show_debug_message($"Warning (scr_inventory_remove_item_from_list): Tried to remove {quantity_to_remove} of {_item_name_for_debug}, but only {items_actually_removed} were found/removed.");
    }
    return items_actually_removed;
}


// You might also want a function to calculate current inventory weight:
/// @function scr_inventory_calculate_weight(target_inventory_list)
function scr_inventory_calculate_weight(target_inventory_list) {
    var total_weight = 0;
    if (!ds_exists(target_inventory_list, ds_type_list)) return 0;

    for (var i = 0; i < ds_list_size(target_inventory_list); i++) {
        var item_stack = target_inventory_list[| i];
        var item_base_data = get_item_data(item_stack.item_id_enum);
        if (item_base_data != undefined && variable_struct_exists(item_base_data, "weight_per_unit")) {
            total_weight += item_stack.quantity * item_base_data.weight_per_unit;
        }
    }
    return total_weight;
}