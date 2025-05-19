/// scr_pop_foraging.gml
///
/// Moves to the target bush, then harvests 1 berry/sec until empty,
/// steps 30px south, then clears target and goes to WAITING.
/// Uses the new struct-based inventory system with item ID “berry”
/// and logs foraging actions with the pop's custom identifier.

function scr_pop_foraging() {

    // =========================================================================
    // ░░░░░ Depth & Arrival Initialization ░░░░░
    // =========================================================================
    #region Depth & Arrival Initialization
    if (!has_arrived) {
        // Ensure target_bush is valid before trying to access its depth
        if (instance_exists(target_bush)) {
            depth        = target_bush.depth - 1000; // Pop appears in front of bush
        } else {
            // If target_bush somehow became invalid before this, handle gracefully
            state        = PopState.WAITING;
            has_arrived  = false; // Keep has_arrived false
            depth        = -y;    // Reset depth
            target_bush  = noone;
            show_debug_message($"Warning (scr_pop_foraging): Pop {pop_identifier_string} target bush invalid during depth init.");
            exit; // Exit script if no valid target
        }
        has_arrived  = true;
        forage_timer = 0;
    }
    #endregion


    // =========================================================================
    // ░░░░░ Validation: Ensure Target Bush Exists (Re-check) ░░░░░
    // =========================================================================
    #region Validation
    if (!instance_exists(target_bush)) {
        target_bush = noone;
        state       = PopState.WAITING;
        depth       = -y;
        has_arrived = false;
        show_debug_message($"Warning (scr_pop_foraging): Pop {pop_identifier_string} target bush became invalid.");
        return; 
    }
    #endregion


    // =========================================================================
    // ░░░░░ Movement: Walk Toward Bush ░░░░░
    // =========================================================================
    #region Movement
    var bx = target_bush.x;
    var by = target_bush.y;
    
    if (point_distance(x, y, bx, by) >= 1) { 
        direction = point_direction(x, y, bx, by);
        speed     = 1.5; 
        scr_update_walk_sprite(); 
    } else {
        x = bx; 
        y = by;
        speed = 0;
    }
    #endregion


    // =========================================================================
    // ░░░░░ Arrival & Harvesting ░░░░░
    // =========================================================================
    #region Arrival & Harvesting
    if (speed == 0 && x == bx && y == by) {
        #region 1. Harvest Loop
        forage_timer += 1; 

        if (forage_timer >= forage_rate) { 
            forage_timer = 0; 

            var _berry_harvested_this_tick = false;

            // 1.1) Remove a berry from the bush
            #region 1.1 Remove from Bush
            if (instance_exists(target_bush)) {
                with (target_bush) {
                    if (variable_instance_exists(id, "berry_count") && berry_count > 0) {
                        berry_count -= 1;
                        _berry_harvested_this_tick = true; 
                        if (berry_count == 0) {
                            if (variable_instance_exists(id, "is_harvestable")) {
                                is_harvestable = false;
                            }
                            if (sprite_exists(spr_empty)) { 
                                sprite_index = spr_empty;
                            }
                        }
                    } else {
                        if (variable_instance_exists(id, "is_harvestable")) {
                             is_harvestable = false; 
                        }
                    }
                }
            } else {
                // 'other' here refers to the pop instance calling this script
                other.state = PopState.WAITING; 
                other.has_arrived = false;
                other.target_bush = noone;
                show_debug_message($"Warning (scr_pop_foraging): Pop {other.pop_identifier_string} target bush destroyed during harvest attempt.");
                return;
            }
            #endregion

            // 1.2) Add to the pop’s inventory IF a berry was actually harvested
            #region 1.2 Add to Inventory
            if (_berry_harvested_this_tick) {
                var _berry_item_id = "berry"; 
                
                scr_inventory_struct_add(_berry_item_id, 1); 
                
                // Updated debug message to use pop_identifier_string
                show_debug_message($"{pop_identifier_string} foraged a '{_berry_item_id}'.");
            }
            #endregion

            // 1.3) If bush is now empty (or became invalid), finish foraging
            #region 1.3 Finish Foraging
            if (!instance_exists(target_bush) || (variable_instance_exists(target_bush,"is_harvestable") && !target_bush.is_harvestable) ) {
                y += 30; 
                depth        = -y;
                target_bush  = noone;
                state        = PopState.WAITING;
                has_arrived  = false;
                show_debug_message($"{pop_identifier_string} finished foraging, bush empty or gone.");
            }
            #endregion
        }
        #endregion
    }
    #endregion
}
