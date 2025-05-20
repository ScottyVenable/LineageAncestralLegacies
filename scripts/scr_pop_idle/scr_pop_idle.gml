/// scr_pop_idle.gml
///
/// Handles the IDLE state:
///   • Switch to idle animation
///   • Pick a random wait time (2–4s by default) or apply special waits
///   • Then transition to WANDERING if not explicitly waiting.

function scr_pop_idle() {
    // 0) Only run if we’re actually in IDLE (this check is good but often redundant
    //    if scr_pop_behavior already ensures it's only called for the IDLE state)
    // if (state != PopState.IDLE) return; // Can be removed if scr_pop_behavior handles this

    // 1) Animation swap: show idle sprite (animated)
    // This logic might be better in a general sprite update script based on state and direction
    if (sprite_index != spr_man_idle) { // Assuming spr_man_idle is the correct generic idle
        sprite_index = spr_man_idle;
        image_speed  = 0.2; // e.g., 5 FPS on a 60 FPS game (0.2 * 30 = 6 frames per anim loop over 0.5s)
                            // Adjust based on your animation length and desired speed.
        image_index  = 0;
    }

    // 2) Ensure we’re not moving
    speed = 0;

    // 3) Determine or refresh idle_target_time if this is the "start" of an idle period
    //    A common pattern is to set a flag like 'has_started_idle_behavior' or check if idle_timer is 0.
    //    If idle_timer is 0, it means we need a new target time.
    if (idle_timer == 0) { // If timer is 0, we are starting a new idle cycle.
        if (was_commanded) {
            idle_target_time = after_command_idle_time * 1000000; // Convert seconds to microseconds
            was_commanded    = false; // Consume this flag
        } else if (is_waiting) {
            // For "is_waiting", we want a very long time, effectively infinite until broken by a new command.
            // Or, simply don't transition to WANDERING if is_waiting is true.
            idle_target_time = 9999999999; // A very large number of microseconds
        } else {
            // Standard idle period
            var secs = random_range(idle_min_sec, idle_max_sec);
            idle_target_time = secs * 1000000; // Convert seconds to microseconds
        }
    }

    // 4) Accumulate real idle time if not in an indefinite wait
    //    If 'is_waiting' is true, the pop should not accumulate towards wandering.
    //    It should only break out of IDLE if 'is_waiting' becomes false (new command) or state changes.
    if (!is_waiting) {
        idle_timer += delta_time; // delta_time is in microseconds
    } else {
        // If explicitly waiting, we might not even need to increment idle_timer,
        // or ensure idle_target_time is so large it's never met.
        // The pop will stay idle until 'is_waiting' is cleared or state changes.
        // We can also simplify the transition logic below.
    }


    // 5) When time’s up (and not explicitly waiting), reset and go wandering
    //    The check `!is_waiting` here is crucial.
    if (!is_waiting && idle_timer >= idle_target_time) {
        idle_timer       = 0; // Reset timer for the next idle/wander cycle
        // idle_target_time will be recalculated next time idle_timer is 0
        // is_waiting remains false (it wasn't true for this condition)
        state            = PopState.WANDERING;
        // show_debug_message(pop_identifier_string + " finished idling, now WANDERING.");
    }
    // If 'is_waiting' is true, this condition `!is_waiting` fails, and it won't transition to WANDERING.
    // It will remain IDLE. State changes for waiting pops should come from external commands.

    // 6) Prevent overlap
    scr_separate_pops();
}