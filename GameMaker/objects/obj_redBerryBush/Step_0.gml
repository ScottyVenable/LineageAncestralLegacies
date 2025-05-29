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
///    Version:         1.2 - [Current Date] (Moved sprite update logic here)


// ——————————————————————————————————————————————————
// 0) Sprite Update Logic (moved to Step Event for continuous updates)
// ——————————————————————————————————————————————————

/// @description Updates the bush sprite based on current_berry_count every step

// =========================================================================
// 0. DEFINE SPRITES (Cached for clarity, though direct use is also fine)
// =========================================================================
var _sprite_full = spr_redBerryBush_full;
var _sprite_empty = spr_bush_empty;

// =========================================================================
// 1. VALIDATE REQUIRED VARIABLES (Essential for this event to function)
// =========================================================================
// These checks ensure the object has the necessary variables.
// If not, it logs an error, which is helpful for debugging.
// Note: For a Step event, constant checks might be a slight performance hit.
// Consider if these are absolutely needed every step or primarily for initial setup debugging.
if (!variable_instance_exists(id, "resource_count")) { // Changed from current_berry_count
    show_debug_message("ERROR (obj_redBerryBush - Step Event): Instance " + string(id) + " is missing 'resource_count' variable.");
    exit; // Exit this event if critical variable is missing
}
if (!variable_instance_exists(id, "max_berries")) { // Changed from max_berry_count
    show_debug_message("ERROR (obj_redBerryBush - Step Event): Instance " + string(id) + " is missing 'max_berries' variable.");
    exit; // Exit this event if critical variable is missing
}

// =========================================================================
// 2. CONFIGURATION & CONSTANTS (Derived from sprite properties)
// =========================================================================
var _full_sprite_berry_stages = sprite_get_number(_sprite_full);

// =========================================================================
// 3. CORE LOGIC: UPDATE SPRITE AND IMAGE_INDEX
// =========================================================================
// Ensure resource_count is within valid bounds (0 to max_berries)
// This might be redundant if resource_count is always managed correctly elsewhere,
// but provides safety.
var _clamped_resource_count = clamp(resource_count, 0, max_berries); // Changed from current_berry_count and max_berry_count

if (_clamped_resource_count == 0) {
    // --- Case 1: No berries ---
    if (sprite_index != _sprite_empty) { // Only change if not already empty
        sprite_index = _sprite_empty;
        image_index = 0;
        image_speed = 0;
    }
} else {
    // --- Case 2: Berries exist ---
    var _new_sprite_index = _sprite_full;
    // Calculate proportion based on resource_count and max_berries
    var _berry_proportion = (max_berries > 0) ? (_clamped_resource_count / max_berries) : 0;
    var _target_frame = floor((1 - _berry_proportion) * (_full_sprite_berry_stages - 1));
    _target_frame = clamp(_target_frame, 0, _full_sprite_berry_stages - 1);

    // Only update sprite and image_index if they need to change, to avoid unnecessary assignments
    if (sprite_index != _new_sprite_index || image_index != _target_frame) {
        sprite_index = _new_sprite_index;
        image_index = _target_frame;
        image_speed = 0;
    }
}


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