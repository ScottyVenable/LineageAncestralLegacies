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

if (resource_count <= 0) { // Use resource_count instead of berry_count
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
            
            berry_regrow_timer += 1; // Increment regrow timer
            if (berry_regrow_timer >= berry_regrow_time) {
                berry_regrow_timer = 0; // Reset regrow timer for the next berry
                resource_count += 1; // Use resource_count
                show_debug_message($"Bush {id}: Regrew 1 item. Count: {resource_count}/{max_berries}"); // Use resource_count

                // As soon as we have any items, it becomes harvestable and sprite changes.
                if (resource_count == 1) { // Use resource_count
                    sprite_index   = spr_full;
                    is_harvestable = true;
                    delay_active   = false; // Delay is over, now in active regrowth or full.
                    berry_delay_timer = 0; // Reset delay timer as it's no longer relevant for this cycle
                }

                // If fully regrown, reset all relevant flags and timers.
                if (resource_count >= max_berries) { // Use resource_count
                    resource_count     = max_berries; // Cap at max, using resource_count
                    is_harvestable     = true;      // Ensure it's harvestable
                    delay_active       = false;     // No longer in delay
                    show_debug_message($"Bush {id}: Fully regrown with {resource_count} items."); // Use resource_count
                }
            }
        }
    }
} else {
    // If items exist (resource_count > 0), ensure it's harvestable and not in delay.
    if (!is_harvestable) {
        is_harvestable = true;
    }
    if (sprite_index != spr_full && sprite_exists(spr_full)) {
        sprite_index = spr_full;
    }
    if (delay_active) { 
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