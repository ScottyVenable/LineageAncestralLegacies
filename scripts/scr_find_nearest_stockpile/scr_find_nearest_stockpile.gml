function scr_find_nearest_item_for_hauling(searcher_x, searcher_y, searcher_inst, type_filter) {
    var nearest_item = noone;
    var min_dist = infinity;

    // Assuming obj_dropped_resource is your object for haulable items
    with (obj_dropped_resource) { 
        // 1. Filter by type_filter if provided
        // if (type_filter != undefined && this.item_id_enum != type_filter) { continue; }

        // 2. Check if already targeted by another pop (if you implement this)
        // if (variable_instance_exists(self, "targeted_by_pop") && 
        //     self.targeted_by_pop != noone && 
        //     self.targeted_by_pop != searcher_inst) {
        //     continue; 
        // }

        // 3. Check if haulable (e.g., not inside a stockpile already, or has a flag)
        // if (is_in_stockpile(self.id)) { continue; } // Requires a helper

        var dist = point_distance(searcher_x, searcher_y, x, y);
        if (dist < min_dist) {
            min_dist = dist;
            nearest_item = id;
        }
    }
    
    // If an item is found, potentially mark it as targeted by searcher_inst here
    // if (instance_exists(nearest_item)) {
    //     nearest_item.targeted_by_pop = searcher_inst;
    // }
    return nearest_item;
}

/// @function scr_find_nearest_stockpile(searcher_x, searcher_y, searcher_inst, type_filter)
/// @description Finds the nearest stockpile that can accept an optional item type
function scr_find_nearest_stockpile(searcher_x, searcher_y, searcher_inst, type_filter) {
    var nearest_sp = noone;
    var min_dist   = infinity;

    // Iterate all instances, but only consider those flagged as stockpiles
    with (all) {
        if (!variable_instance_exists(id, "is_stockpile") || !is_stockpile) {
            continue;
        }
        // Existing type_filter check...
        if (argument_count >= 4 && script_exists(scr_stockpile_can_accept_item)) {
            var ok = scr_stockpile_can_accept_item(id, type_filter);
            if (!ok) continue;
        }
        // Distance test
        var d = point_distance(searcher_x, searcher_y, x, y);
        if (d < min_dist) {
            min_dist   = d;
            nearest_sp = id;
        }
    }
    return nearest_sp;
}