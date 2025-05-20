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
///    Version:         1.2 - [Current Date] (Corrected debug message line)
///    Dependencies:  par_slot_provider, room_speed, relevant sprite assets.

event_inherited(); // Inherit from par_slot_provider. This runs parent's Create event.

// ============================================================================
// 1. BUSH-SPECIFIC HARVESTABLE PROPERTIES
// ============================================================================
#region 1.1 Harvestable Stock
max_berries = 10;
berry_count = max_berries;
#endregion

#region 1.2 Regrowth Timing
BERRY_REGROW_DURATION_SECONDS = 3.0;
BERRY_DELAY_DURATION_SECONDS  = 20.0;
berry_regrow_time   = BERRY_REGROW_DURATION_SECONDS * room_speed;
berry_delay_time    = BERRY_DELAY_DURATION_SECONDS * room_speed;
berry_regrow_timer  = 0;
berry_delay_timer   = 0;
delay_active        = false;
#endregion

// ============================================================================
// 2. INTERACTION SLOT CONFIGURATION (Overrides/defines for this bush type)
// ============================================================================
#region 2.1 Define Interaction Slots
max_interaction_slots = 2;
init_interaction_slots(); 

var slot_offset_x_distance = 24; 
var slot_offset_y_distance = 0;  

if (max_interaction_slots > 0) {
    interaction_slot_positions[0] = { 
        rel_x: -slot_offset_x_distance, 
        rel_y: slot_offset_y_distance, 
        interaction_type_tag: "forage_left" 
    };
}

if (max_interaction_slots > 1) {
    interaction_slot_positions[1] = { 
        rel_x: slot_offset_x_distance, 
        rel_y: slot_offset_y_distance, 
        interaction_type_tag: "forage_right" 
    };
}
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
spr_empty           = spr_bush_empty;      

if (sprite_exists(spr_full) && sprite_exists(spr_empty)) {
    sprite_index    = (berry_count > 0) ? spr_full : spr_empty;
} else {
    show_debug_message($"ERROR (obj_redBerryBush Create): Bush sprites (spr_full or spr_empty) not found for ID {id}!");
}
#endregion

// ============================================================================
// 5. INTERACTION FLAGS & DEPTH
// ============================================================================
#region 5.1 Interaction Flags
is_harvestable      = (berry_count > 0);
#endregion

#region 5.2 Depth Sorting
depth = -y;
#endregion

// ============================================================================
// 6. INITIALIZATION COMPLETE LOG
// ============================================================================
#region 6.1 Debug Log
// Corrected debug message line:
show_debug_message($"Bush {id} created. Max Slots: {max_interaction_slots}. Berries: {berry_count}. Regrow Time: {berry_regrow_time} steps. Delay Time: {berry_delay_time} steps.");
#endregion