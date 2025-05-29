/// obj_redBerryBush – Create Event
///
/// Purpose:
///    Initializes the berry bush's properties, including its berry stock,
///    regrowth timing, interaction slots, and initial state. Inherits from
///    par_slot_provider.
///
/// Metadata:
///    Summary:         Sets up the bush for harvesting and regrowth with defined work slots.
///    Usage:           obj_redBerryBush Create Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [world_object][harvestable][resource][init][slot_provider_child]
///    Version:         1.3 - [Current Date] (Updated to use standardized instance variables for foraging)
///    Dependencies:  par_slot_provider, room_speed, relevant sprite assets.

event_inherited(); // Inherit from par_slot_provider. This runs parent's Create event.

// ============================================================================
// 1. BUSH-SPECIFIC HARVESTABLE PROPERTIES
// ============================================================================
#region 1.1 Harvestable Stock
// resource = get_resource_data(Resource.RED_BERRY_BUSH) // This can be kept for other uses if needed
resource_count = 10; // Standardized: How many items are available
item_yield_enum = Item.FOOD_RED_BERRY; // Standardized: What item this bush yields (ensure Item.FOOD_RED_BERRY is defined in your Item enum)
yield_quantity_per_cycle = 1; // Standardized: How many items are gathered per foraging cycle
// berry_count = 10; // Replaced by resource_count
max_berries = resource_count; // Initialize max_berries with the initial resource_count. This is used for sprite frame calculation.
// current_berry_count has been removed as resource_count serves its purpose.
#endregion

#region 1.2 Regrowth Timing
BERRY_REGROW_DURATION_SECONDS = 3;
BERRY_DELAY_DURATION_SECONDS  = 20.0;
berry_regrow_time   = BERRY_REGROW_DURATION_SECONDS * global.game_speed;
berry_delay_time    = BERRY_DELAY_DURATION_SECONDS * global.game_speed;
berry_regrow_timer  = 0;
berry_delay_timer   = 0;
delay_active        = false;
#endregion

// ============================================================================
// 2. INTERACTION SLOT CONFIGURATION (Overrides/defines for this bush type)
//    NOW GENERATES obj_interaction_point INSTANCES
// ============================================================================
#region 2.1 Define Interaction Slots & Create Points
max_interaction_slots = 2;
// interaction_slots_pop_ids is now an array to store the instance IDs of the created obj_interaction_point instances.
// It will still be sized by max_interaction_slots by the parent's init script.
global.init_interaction_slots(); // This likely initializes interaction_slots_pop_ids to be an array of `noone`
                                 // We will now fill it with instance IDs of obj_interaction_point.

// We need a new array to store the actual obj_interaction_point instance IDs
// The parent script (par_slot_provider) might initialize interaction_slots_pop_ids.
// Let's use a more descriptive name for clarity if we are changing its purpose, or adapt.
// For now, let's assume interaction_slots_pop_ids will store the point IDs.
// If par_slot_provider uses interaction_slots_pop_ids for pop IDs directly, this will need adjustment there too.

var slot_offset_x_distance = 24;
var slot_offset_y_distance = 0;

// Temporary array to hold the definitions, which we'll then use to create points.
var _slot_definitions = [];
if (max_interaction_slots > 0) {
    array_push(_slot_definitions, {
        rel_x: -slot_offset_x_distance,
        rel_y: slot_offset_y_distance,
        interaction_type_tag: "forage_left"
    });
}
if (max_interaction_slots > 1) {
    array_push(_slot_definitions, {
        rel_x: slot_offset_x_distance,
        rel_y: slot_offset_y_distance,
        interaction_type_tag: "forage_right"
    });
}
// Add more slots here if max_interaction_slots is higher, following the pattern.

// Now, create the obj_interaction_point instances
for (var i = 0; i < array_length(_slot_definitions); i++) {
    if (i < max_interaction_slots) { // Ensure we don't create more points than max_interaction_slots allows
        var _slot_def = _slot_definitions[i];
        var _point_x = x + _slot_def.rel_x;
        var _point_y = y + _slot_def.rel_y;
        
        // Create the interaction point instance on a specific layer if you have one for them,
        // otherwise, it will be on the same layer as the bush.
        // var _interaction_point_layer = layer_get_id("InteractionPointsLayer"); // Example layer
        // var _point_inst = instance_create_layer(_point_x, _point_y, _interaction_point_layer, obj_interaction_point);
        var _point_inst = instance_create_depth(_point_x, _point_y, depth - 1, obj_interaction_point); // Create slightly in front of bush

        if (instance_exists(_point_inst)) {
            _point_inst.parent_provider_id = id; // Link back to this bush
            _point_inst.slot_index_on_parent = i;
            _point_inst.interaction_type_tag = _slot_def.interaction_type_tag;
            
            // Store the ID of the created interaction point in the bush's array.
            // This array was previously interaction_slots_pop_ids, now it stores point instance IDs.
            interaction_slots_pop_ids[i] = _point_inst.id;
            
            debug_log($"Created obj_interaction_point ({_point_inst.id}) for bush {id}, slot {i} at ({_point_x}, {_point_y}) with tag \"{_slot_def.interaction_type_tag}\".", "obj_redBerryBush:Create", "blue");
        } else {
            debug_log($"ERROR: Failed to create obj_interaction_point for slot {i} on bush {id}.", "obj_redBerryBush:Create", "red");
        }
    } else {
        // This case should ideally not be hit if _slot_definitions is sized correctly based on max_interaction_slots.
        interaction_slots_pop_ids[i] = noone; // Ensure any remaining slots in the array are marked as noone.
    }
}

// The interaction_slot_positions array (which stored structs of rel_x, rel_y, tag)
// is no longer directly needed by this object if all slot data is now on the obj_interaction_point instances.
// However, other scripts might still expect it. For now, let's clear it or decide if it should be removed.
// For safety during transition, we can leave it, but it won't be the primary source of truth for slot positions/tags.
// interaction_slot_positions = []; // Optional: clear if no longer used by any system.

#endregion

// ============================================================================
// 3. PHYSICS-BASED SWAY
// ============================================================================
#region 3.1 Sway Parameters
sway_angle          = 0;    
sway_velocity       = 0;
sway_stiffness      = 0.3;
sway_damping        = 0.25;
sway_impulse        = 10;
is_wiggling         = false;
#endregion

// ============================================================================
// 4. SPRITES & INITIAL APPEARANCE
// ============================================================================
#region 4.1 Sprites
spr_full            = spr_redBerryBush_full;
spr_empty           = spr_bush_empty;      // Standardized: Sprite to show when depleted

// Initialize sprite_index based on the initial resource_count.
// The Step event will handle dynamic updates if spr_redBerryBush_full is animated.
if (sprite_exists(spr_full) && sprite_exists(spr_empty)) {
    sprite_index    = (resource_count > 0) ? spr_full : spr_empty;
    if (resource_count > 0 && sprite_get_number(spr_full) > 1) {
        // If the full sprite is animated, set to the last frame initially (most full)
        // The Step event logic calculates frame based on (1 - proportion), so frame 0 is most full.
        image_index = 0; // Start at the 'most full' frame
    } else {
        image_index = 0; // For single-frame sprites or empty sprite
    }
    image_speed = 0; // Animation will be handled by Step event logic if needed
} else {
    debug_log($"ERROR (Bush sprites (spr_full or spr_empty) not found for ID {id}!)", "obj_redBerryBush:Create", "red");
}
#endregion

// ============================================================================
// 5. INTERACTION FLAGS & DEPTH
// ============================================================================
#region 5.1 Interaction Flags
is_harvestable      = (resource_count > 0); // Standardized: Is it currently harvestable, based on resource_count
#endregion

#region 5.2 Depth Sorting
depth = -y;
#endregion

// ============================================================================
// 6. INITIALIZATION COMPLETE LOG
// ============================================================================
#region 6.1 Debug Log
// Corrected debug message line:
debug_log($"Bush {id} created. Max Slots: {max_interaction_slots}. Berries: {resource_count}. Regrow Time: {berry_regrow_time} steps. Delay Time: {berry_delay_time} steps.", "obj_redBerryBush:Create", "green");
#endregion

// Initialize berry count variables
// max_berry_count = 7; // This is now set in the main #region 1.1 based on resource_count
// current_berry_count = max_berry_count; // This is also effectively set by resource_count initialization

// Initial sprite update is now handled by the Step Event, so no explicit call needed here.
// event_user(0); // This call is removed as logic is moved to Step Event

// Ensure max_berry_count is available for the Step event if it relies on it before full init.
// However