if (variable_instance_exists(id, "inventory_items") && !ds_list_empty(inventory_items)) {
    for (var i = ds_list_size(inventory_items) - 1; i >= 0; i--) { // Iterate backwards if removing
        var item_stack_struct = inventory_items[| i];
        var item_enum = item_stack_struct.item_id_enum;
        var item_qty = item_stack_struct.quantity;
        var item_data = get_item_data(item_enum);
        
        if (item_data != undefined) {
            show_debug_message("Pop " + string(id) + " dropping off " + string(item_qty) + " of " + item_data.name + ".");
            // Add to appropriate global stock based on item type or specific enum
            switch (item_enum) {
                case Item.FOOD_RED_BERRY:
                    global.lineage_food_stock += item_qty;
                    // --- Show floating dropoff text above the hut ---
                    if (sprite_exists(spr_ui_icons_food)) {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, spr_ui_icons_food);
                    } else {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, -1); // No sprite fallback
                    }
                    break;
                case Item.MATERIAL_WOOD:
                    global.lineage_wood_stock += item_qty;
                    if (sprite_exists(spr_ui_icons_wood)) {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, spr_ui_icons_wood);
                    } else {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, -1);
                    }
                    break;
                case Item.MATERIAL_STONE:
                    global.lineage_stone_stock += item_qty;
                    if (sprite_exists(spr_ui_icons_stone)) {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, spr_ui_icons_stone);
                    } else {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, -1);
                    }
                    break;
                case Item.MATERIAL_METAL_ORE:
                    global.lineage_metal_stock += item_qty;
                    if (sprite_exists(spr_ui_icons_metal)) {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, spr_ui_icons_metal);
                    } else {
                        scr_ui_showDropoffText(target_object_id.x, target_object_id.y - 48, item_qty, -1);
                    }
                    break;
                // Add more cases for other item types as needed
                default:
                    show_debug_message("Item " + item_data.name + " is not designated for global stock in hauling script.");
                    break;
            }
        }
    }
    // Clear the pop's inventory after dropping everything off
    ds_list_clear(inventory_items); 
    // self.current_inventory_weight = 0; // Reset if using weight system
    show_debug_message("Pop " + string(id) + " (" + pop_name + ") inventory cleared after hauling.");
}