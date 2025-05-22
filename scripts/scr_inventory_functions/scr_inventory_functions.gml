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
    if (!ds_exists(target_inventory_list, ds_type_list)) {
        show_debug_message("Error (scr_inventory_add_item): Invalid target_inventory_list provided.");
        return quantity_to_add; // Cannot add
    }

    var item_base_data = get_item_data(item_to_add_enum);
    if (item_base_data == undefined) {
        show_debug_message($"Error (scr_inventory_add_item): Unknown item enum: {item_to_add_enum}. Cannot add.");
        return quantity_to_add; // Cannot add
    }

    var max_stack_size = (variable_struct_exists(item_base_data, "max_stack")) ? item_base_data.max_stack : 1;
    var item_weight = (variable_struct_exists(item_base_data, "weight_per_unit")) ? item_base_data.weight_per_unit : 0;
    var items_remaining_to_add = quantity_to_add;

    // --- Stage 1: Try to stack with existing items of the same type ---
    if (max_stack_size > 1) { // Only try to stack if the item is stackable
        for (var i = 0; i < ds_list_size(target_inventory_list); i++) {
            var existing_item_stack_struct = target_inventory_list[| i];
            
            // Check if it's the same item type and has space
            if (existing_item_stack_struct.item_id_enum == item_to_add_enum &&
                existing_item_stack_struct.quantity < max_stack_size) {
                
                var space_in_stack = max_stack_size - existing_item_stack_struct.quantity;
                var amount_to_actually_stack = min(items_remaining_to_add, space_in_stack);
                
                if (amount_to_actually_stack > 0) {
                    // TODO: Check weight capacity before adding (if implementing inventory_capacity_weight)
                    // var weight_to_add = amount_to_actually_stack * item_weight;
                    // if (self.current_inventory_weight + weight_to_add <= self.inventory_capacity_weight) {
                    //    self.current_inventory_weight += weight_to_add;
                         existing_item_stack_struct.quantity += amount_to_actually_stack;
                         items_remaining_to_add -= amount_to_actually_stack;
                         show_debug_message($"Stacked {amount_to_actually_stack} of {item_base_data.name}. New stack size: {existing_item_stack_struct.quantity}");
                    // } else {
                    //    show_debug_message("Cannot stack due to weight capacity.");
                    //    break; // Stop trying to stack if overweight
                    // }
                }
            }
            if (items_remaining_to_add <= 0) {
                break; // All items have been added
            }
        }
    }

    // --- Stage 2: If items still remain, create new stacks ---
    while (items_remaining_to_add > 0) {
        var amount_for_new_stack = min(items_remaining_to_add, max_stack_size);
        
        // TODO: Check weight capacity before adding a new stack
        // var weight_to_add = amount_for_new_stack * item_weight;
        // if (self.current_inventory_weight + weight_to_add <= self.inventory_capacity_weight) {
        //    self.current_inventory_weight += weight_to_add;
            var new_item_stack_struct = {
                item_id_enum: item_to_add_enum,
                quantity: amount_for_new_stack
                // Add instance-specific properties if needed (e.g., for tools)
            };
            // For items with durability, like tools (not berries)
            if (variable_struct_exists(item_base_data, "durability_max")) {
                new_item_stack_struct.durability = item_base_data.durability_max;
            }

            ds_list_add(target_inventory_list, new_item_stack_struct);
            items_remaining_to_add -= amount_for_new_stack;
            show_debug_message($"Created new stack of {item_base_data.name} with quantity {amount_for_new_stack}.");
        // } else {
        //    show_debug_message("Cannot create new stack due to weight capacity.");
        //    break; // Stop creating new stacks if overweight
        // }
    }
    
    if (items_remaining_to_add > 0) {
        show_debug_message($"Warning (scr_inventory_add_item): Could not add {items_remaining_to_add} of {item_base_data.name}. Inventory might be full or other constraints.");
    }
    return items_remaining_to_add; // Return how many couldn't be added
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