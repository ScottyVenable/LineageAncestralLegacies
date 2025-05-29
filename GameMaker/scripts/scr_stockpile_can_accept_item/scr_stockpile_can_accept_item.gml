/// @function scr_stockpile_can_accept_item(stockpile_inst, item_filter)
/// @description Returns true if stockpile_inst can accept the given item enum or ds_list of stacks
function scr_stockpile_can_accept_item(stockpile_inst, item_filter) {
    // Only consider instances tagged as stockpiles
    if (!variable_instance_exists(stockpile_inst, "is_stockpile") || !stockpile_inst.is_stockpile) {
        return false;
    }
    // If this stockpile defines accepted_item_tags, enforce them
    if (variable_instance_exists(stockpile_inst, "accepted_item_tags")) {
        // Normalize filter to a list of enums
        var enums = [];
        if (ds_exists(item_filter, ds_type_list)) {
            for (var i = 0; i < ds_list_size(item_filter); i++) {
                var stack = item_filter[| i];
                if (is_struct(stack) && variable_struct_exists(stack, "item_id_enum"))
                    array_push(enums, stack.item_id_enum);
            }
        } else {
            array_push(enums, item_filter);
        }
        // For each enum, check its tags
        for (var j = 0; j < array_length(enums); j++) {
            var enum_val = enums[j];
            var data = get_item_data(enum_val);
            if (!is_struct(data) || !variable_struct_exists(data, "tags")) continue;
            // If any tag matches one in the stockpile’s accepted_item_tags, allow it
            for (var t = 0; t < array_length(data.tags); t++) {
                if (array_contains(stockpile_inst.accepted_item_tags, data.tags[t])) {
                    return true;
                }
            }
        }
        return false;
    }
    // Fallback: no tag list means accept anything
    return true;
}
