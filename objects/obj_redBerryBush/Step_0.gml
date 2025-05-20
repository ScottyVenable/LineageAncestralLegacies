/// obj_redBerryBush – Step Event
///
/// Purpose:
///    Handles the regrowth logic for berries after the bush has been depleted.
///    Also manages a physics-based sway effect when pops interact.
///
/// Metadata:
///    Summary:         Manages regrowth timers, berry count, and visual sway.
///    Usage:           obj_redBerryBush Step Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [world_object][harvestable][resource][update][physics_lite]
///    Version:         1.1 - [Current Date] (Using initialized _time variables)


// ——————————————————————————————————————————————————
// 1) Bush Regrowth Logic
// ——————————————————————————————————————————————————
// This logic assumes timers increment by 1 each step, and _time variables are in steps.

if (berry_count <= 0) {
    // Bush is empty, manage regrowth delay and then regrowth.
    if (!delay_active) {
        // If delay hasn't started yet, activate it and reset its timer.
        delay_active      = true;
        berry_delay_timer = 0; // Reset delay timer when delay phase begins
        berry_regrow_timer = 0; // Also reset regrow timer, as it only starts after delay
        is_harvestable = false; // Ensure it's not harvestable
        if (sprite_index != spr_empty && sprite_exists(spr_empty)) { // Ensure empty sprite is set
            sprite_index = spr_empty;
        }
        show_debug_message($"Bush {id}: Delay phase started. Will wait for {berry_delay_time} steps.");
    }

    // Increment delay timer if in delay phase
    if (delay_active) {
        berry_delay_timer += 1;

        if (berry_delay_timer >= berry_delay_time) {
            // Delay has finished. Now start regrowing berries.
            // We don't need to set delay_active = false here yet,
            // as that will happen once berries start appearing or it's fully regrown.
            
            berry_regrow_timer += 1; // Increment regrow timer
            if (berry_regrow_timer >= berry_regrow_time) {
                berry_regrow_timer = 0; // Reset regrow timer for the next berry
                berry_count += 1;
                show_debug_message($"Bush {id}: Regrew 1 berry. Count: {berry_count}/{max_berries}");

                // As soon as we have any berries, it becomes harvestable and sprite changes.
                // Also, the initial delay phase is effectively over once regrowth starts.
                if (berry_count == 1) {
                    sprite_index   = spr_full;
                    is_harvestable = true;
                    delay_active   = false; // Delay is over, now in active regrowth or full.
                    berry_delay_timer = 0; // Reset delay timer as it's no longer relevant for this cycle
                }

                // If fully regrown, reset all relevant flags and timers.
                if (berry_count >= max_berries) {
                    berry_count        = max_berries; // Cap at max
                    is_harvestable     = true;      // Ensure it's harvestable
                    delay_active       = false;     // No longer in delay
                    // berry_delay_timer is already 0 or will be reset if it enters delay again
                    // berry_regrow_timer is already 0
                    show_debug_message($"Bush {id}: Fully regrown with {berry_count} berries.");
                }
            }
        }
    }
} else {
    // If berries exist (berry_count > 0), ensure it's harvestable and not in delay.
    // This state is typically reached if it was harvested but not fully, or after regrowing some.
    if (!is_harvestable) {
        is_harvestable = true;
    }
    if (sprite_index != spr_full && sprite_exists(spr_full)) {
        sprite_index = spr_full;
    }
    // If it has berries, any active delay or specific regrowth timing should be reset.
    // This part might be redundant if the logic above correctly transitions out of delay_active.
    // However, ensuring these are reset if berries > 0 and it wasn't caught by the above logic is safe.
    if (delay_active) { // If it somehow has berries but delay_active is true, fix it.
        delay_active = false;
        berry_delay_timer = 0;
        berry_regrow_timer = 0;
    }
}


// ——————————————————————————————————————————————————
// 2) Physics-Based Sway (always update)
// ——————————————————————————————————————————————————

// A) Detect a pop overlapping the bush’s collision mask
if (!is_wiggling) {
    var p = instance_place(x, y, obj_pop);
    if (p != noone) {
        is_wiggling    = true;
        // Give a random directional kick to the sway velocity
        sway_velocity += choose(-1, 1) * sway_impulse;
    }
}

// B) Spring-damper integration each frame
if (is_wiggling) {
    // Compute spring force (−k·angle) and damping (−c·velocity)
    var spring_force   = -sway_stiffness * sway_angle;
    var damping_force  = -sway_damping   * sway_velocity;
    var angular_accel  = spring_force + damping_force;

    // Integrate velocity and angle
    sway_velocity += angular_accel;
    sway_angle    += sway_velocity;

    // Apply to the drawn rotation
    image_angle = sway_angle;

    // If the motion has essentially settled, stop updating
    if (abs(sway_velocity) < 0.01 && abs(sway_angle) < 0.1) {
        sway_velocity = 0;
        sway_angle    = 0;
        image_angle   = 0;
        is_wiggling   = false;
    }
}

// ——————————————————————————————————————————————————
// 3) Depth Sorting
// ——————————————————————————————————————————————————

depth = -y;