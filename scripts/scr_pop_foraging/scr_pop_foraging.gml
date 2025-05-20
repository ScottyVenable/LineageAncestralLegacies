/// scr_pop_foraging.gml (or scr_pop_interaction_work.gml)
///
/// Purpose:
///   Handles the behavior for a pop that is tasked with an interaction
///   at a specific slot on a target object (e.g., foraging from a bush).
///   Manages movement to the slot, performing the interaction using correct
///   directional sprites (pop faces the target), and releasing the slot.
///   Relies on sprite's internal animation speed for foraging animations.
///
/// Metadata:
///   Summary:       Move to slot, perform work (e.g., forage) with correct facing sprite, release slot.
///   Usage:         Called by scr_pop_behavior when state is PopState.FORAGING (or a generic WORKING state).
///   Version:       1.2 - [Current Date] (Sprite direction logic reversed for facing, image_speed not overridden for foraging)
///   Dependencies:  scr_interaction_slot_get_world_pos, scr_interaction_slot_release,
///                  scr_update_walk_sprite, scr_inventory_struct_add, PopState (enum),
///                  Instance variables: target_interaction_object_id, target_interaction_slot_index,
///                  target_interaction_type_tag, travel_point_x/y, has_arrived, forage_timer, forage_rate,
///                  spr_man_foraging_left, spr_man_foraging_right, spr_man_idle.

function scr_pop_foraging() { // Or your generic interaction script name

    // =========================================================================
    // 0. VALIDATION
    // =========================================================================
    #region 0.1 Validate Interaction Target
    if (!instance_exists(target_interaction_object_id) || 
        target_interaction_slot_index == -1 ||
        !variable_instance_exists(target_interaction_object_id, "interaction_slot_positions") ||
        target_interaction_slot_index >= array_length(target_interaction_object_id.interaction_slot_positions)) {

        if (instance_exists(target_interaction_object_id) && target_interaction_slot_index != -1) {
             scr_interaction_slot_release(target_interaction_object_id, id);
        }
        target_interaction_object_id = noone; target_interaction_slot_index = -1; target_interaction_type_tag = "";
        state = PopState.WAITING; is_waiting = true; depth = -y; has_arrived = true; speed = 0;
        image_speed = 1.0; // Reset to default for idle/waiting
        sprite_index = spr_man_idle;
        show_debug_message($"Pop {pop_identifier_string} (ID: {id}) has invalid interaction target/slot. Reverting to WAITING.");
        exit;
    }
    #endregion

    var _slot_details = scr_interaction_slot_get_world_pos(target_interaction_object_id, target_interaction_slot_index);
    
    if (_slot_details == undefined) {
        show_debug_message($"Pop {pop_identifier_string} (ID: {id}) could not retrieve slot details. Reverting to WAITING.");
        scr_interaction_slot_release(target_interaction_object_id, id);
        target_interaction_object_id = noone; target_interaction_slot_index = -1; target_interaction_type_tag = "";
        state = PopState.WAITING; is_waiting = true; depth = -y; has_arrived = true; speed = 0; image_speed = 1.0; sprite_index = spr_man_idle;
        exit;
    }
    var _slot_target_x = _slot_details.x;
    var _slot_target_y = _slot_details.y;

    // =========================================================================
    // 1. MOVEMENT TO ASSIGNED SLOT
    // =========================================================================
    #region 1.1 Movement to Slot
    if (!has_arrived) {
        depth = target_interaction_object_id.depth - 1; 
        if (point_distance(x, y, _slot_target_x, _slot_target_y) >= 2) {
            direction = point_direction(x, y, _slot_target_x, _slot_target_y);
            speed = 1.5; 
            image_speed = 1.5; // Set walk animation speed (if different from default)
            scr_update_walk_sprite(); 
            exit; 
        } else {
            x = _slot_target_x; y = _slot_target_y; speed = 0; has_arrived = true; 
            image_speed = 1.0; // Reset walk animation speed upon arrival at slot
            if (target_interaction_type_tag == "forage_left" || target_interaction_type_tag == "forage_right") {
                forage_timer = 0;
            }
            show_debug_message($"Pop {pop_identifier_string} (ID: {id}) arrived at slot {target_interaction_slot_index} for target {target_interaction_object_id}. Type: '{target_interaction_type_tag}'.");
        }
    }
    #endregion

    // =========================================================================
    // 2. PERFORMING INTERACTION AT SLOT
    // =========================================================================
    #region 2.1 Interaction Logic
    depth = target_interaction_object_id.depth - 1;
    // Pop should face the center of the interaction object
    direction = point_direction(x, y, target_interaction_object_id.x, target_interaction_object_id.y);

    switch (target_interaction_type_tag) {
        case "forage_left": // This tag means the SLOT is on the LEFT of the bush
            sprite_index = spr_man_foraging_right; // Pop FACES RIGHT (towards bush)
            // image_speed is NOT set here; uses sprite's default animation speed
            break; 
        case "forage_right": // This tag means the SLOT is on the RIGHT of the bush
            sprite_index = spr_man_foraging_left;  // Pop FACES LEFT (towards bush)
            // image_speed is NOT set here; uses sprite's default animation speed
            break;
            
        // Add other interaction_type_tags here if needed for other tasks
        // case "mine_rock_front": sprite_index = spr_man_mining_front; break;
            
        default:
            // Fallback if tag is unknown or if it's a non-directional interaction
            sprite_index = spr_man_idle; // Or a generic "working" sprite
            image_speed = 0.2; // Example for a generic idle/work if no specific animation
            show_debug_message($"Pop {pop_identifier_string} (ID: {id}) at slot with unhandled/generic tag: '{target_interaction_type_tag}'. Using fallback sprite.");
            break;
    }
    
    // --- Foraging specific logic (if current tag is for foraging) ---
    if (target_interaction_type_tag == "forage_left" || target_interaction_type_tag == "forage_right") {
        forage_timer += 1;
        if (forage_timer >= forage_rate) {
            forage_timer = 0;
            var _item_harvested_this_tick = false;
            var _target_is_depleted = false;

            if (instance_exists(target_interaction_object_id) && 
                variable_instance_exists(target_interaction_object_id, "is_harvestable") &&
                target_interaction_object_id.is_harvestable &&
                variable_instance_exists(target_interaction_object_id, "berry_count")) {

                if (target_interaction_object_id.berry_count > 0) {
                    target_interaction_object_id.berry_count -= 1;
                    _item_harvested_this_tick = true;
                    if (target_interaction_object_id.berry_count == 0) {
                        target_interaction_object_id.is_harvestable = false;
                        if (sprite_exists(target_interaction_object_id.spr_empty)) {
                             target_interaction_object_id.sprite_index = target_interaction_object_id.spr_empty;
                        }
                        _target_is_depleted = true;
                    }
                } else {
                    _target_is_depleted = true;
                    target_interaction_object_id.is_harvestable = false;
                }
            } else {
                 _target_is_depleted = true; 
            }

            if (_item_harvested_this_tick) {
                scr_inventory_struct_add("berry", 1);
            }

            if (_target_is_depleted) {
                show_debug_message($"Pop {pop_identifier_string} (ID: {id}) finished: target {target_interaction_object_id} depleted or invalid.");
                scr_interaction_slot_release(target_interaction_object_id, id);
                target_interaction_object_id = noone; target_interaction_slot_index = -1; target_interaction_type_tag = "";
                state = PopState.WAITING; is_waiting = true; has_arrived = false; 
                image_speed = 1.0; // Reset to default anim speed for waiting/idle
                sprite_index = spr_man_idle; // Set to idle sprite
                depth = -y;
                exit;
            }
        }
    }
    // No scr_separate_pops() here as the pop should be fixed at its slot while working.
    // Separation is more for general movement and idling.
    #endregion
}