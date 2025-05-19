/// obj_redBerryBush – Step Event

// ——————————————————————————————————————————————————
// 1) Bush Regrowth Logic
// ——————————————————————————————————————————————————

// If the bush is empty, start/continue the 10-s delay
if (berry_count <= 0) {
    if (!delay_active) {
        delay_active      = true;
        berry_delay_timer = 0;
    }
    berry_delay_timer += 1;

    // After delay elapses, regrow 1 berry per second
    if (berry_delay_timer >= berry_delay_time) {
        berry_regrow_timer += 1;
        if (berry_regrow_timer >= berry_regrow_time) {
            berry_regrow_timer -= berry_regrow_time;
            berry_count += 1;

            // As soon as we have any berries, swap back to full art
            if (berry_count == 1) {
                sprite_index   = spr_full;
                is_harvestable = true;
            }

            // Once fully regrown, reset all timers
            if (berry_count >= max_berries) {
                berry_count        = max_berries;
                delay_active       = false;
                berry_delay_timer  = 0;
                berry_regrow_timer = 0;
            }
        }
    }
} else {
    // If berries remain, clear delay/regrow accumulators
    delay_active       = false;
    berry_delay_timer  = 0;
    berry_regrow_timer = 0;
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
