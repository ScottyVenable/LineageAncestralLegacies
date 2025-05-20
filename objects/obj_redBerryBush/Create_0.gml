/// obj_redBerryBush – Create Event
///
/// Purpose:
///    Initializes the berry bush's properties, including its berry stock,
///    regrowth timing parameters, and initial state.
///
/// Metadata:
///    Summary:         Sets up the bush for harvesting and regrowth.
///    Usage:           obj_redBerryBush Create Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [world_object][harvestable][resource][init]
///    Version:         1.2 — [Current Date] (Initialized _time variables and corrected delay_active)

// —— Harvestable stock ——
max_berries         = 10;   // How many berries this bush can hold at once
berry_count         = max_berries; // Current berries remaining (starts full)

// —— Regrowth timing (Durations are in SECONDS for constants) ——
// These are conceptual constants defining the desired duration in seconds.
BERRY_REGROW_DURATION_SECONDS = 3.0;  // Target: 3 seconds to regrow one berry
BERRY_DELAY_DURATION_SECONDS  = 20.0; // Target: 20-second delay before regrowth can start

// Actual timer target values (in game steps/frames) - THESE ARE THE INSTANCE VARIABLES TO USE
// Convert seconds to game steps by multiplying by room_speed.
berry_regrow_time   = BERRY_REGROW_DURATION_SECONDS * room_speed; // <<<<< ADDED THIS
berry_delay_time    = BERRY_DELAY_DURATION_SECONDS * room_speed;  // <<<<< ADDED THIS

// Timer accumulators (these will count up by 1 per step in the Step Event)
berry_regrow_timer  = 0;    // Tracks time towards regrowing the next berry
berry_delay_timer   = 0;    // Tracks time for the initial delay after being emptied
delay_active        = false;  // True if the bush is currently in its regrowth delay period (RENAMED from is_in_delay_phase for consistency with Step)

// —— Physics-based sway parameters ——
sway_angle          = 0;    
sway_velocity       = 0;
sway_stiffness      = 0.3;   // Spring strength
sway_damping        = 0.25;  // Energy loss per frame
sway_impulse        = 10;    // Degrees/sec initial kick
is_wiggling         = false; // This is for the visual sway, distinct from regrowth delay

// —— Sprites ——
// Ensure these sprite assets exist in your project
spr_full            = spr_redBerryBush_full; // Assign your actual full bush sprite
spr_empty           = spr_bush_empty;        // Assign your actual empty bush sprite

// Initialize sprite based on berry_count
if (sprite_exists(spr_full) && sprite_exists(spr_empty)) {
    sprite_index    = (berry_count > 0) ? spr_full : spr_empty;
} else {
    show_debug_message("ERROR: Bush sprites (spr_full or spr_empty) not found for obj_redBerryBush!");
    // sprite_index = -1; // Or some default/error sprite
}

// —— Interaction flags ——
is_harvestable      = (berry_count > 0);

// —— Depth sorting ——
depth = -y;

show_debug_message($"Bush {id} created. Regrow time: {berry_regrow_time} steps, Delay time: {berry_delay_time} steps");