/// scr_pop_idle.gml
///
/// Handles the IDLE state:
///   • Switch to idle animation
///   • Pick a random wait time (2–4s by default)
///   • Apply special waits after commands or during “waiting” mode
///   • Then transition to WANDERING

function scr_pop_idle() {
    // 0) Only run if we’re actually in IDLE
    if (state != PopState.IDLE) return;

    // 1) Animation swap: show idle sprite (animated)
    if (sprite_index != spr_man_idle) {
        sprite_index = spr_man_idle;
        image_speed  = 0.2;    // e.g. 5 FPS on a 60hz step
        image_index  = 0;
    }

    // 2) Ensure we’re not moving
    speed = 0;

    // 3) Decide which timers to use
    if (was_commanded) {
        idle_target_time = after_command_idle_time * 1_000_000;
        was_commanded    = false;
    }
    else if (is_waiting) {
        idle_target_time = 9_999_999_999;
    }
    else {
        if (idle_timer == 0) {
            var secs = random_range(idle_min_sec, idle_max_sec);
            idle_target_time = secs * 1_000_000;
        }
    }

    // 4) Accumulate real idle time
    idle_timer += delta_time;

    // 5) When time’s up, reset and go wandering
    if (idle_timer > idle_target_time) {
        idle_timer       = 0;
        idle_target_time = 0;
        is_waiting       = false;
        state            = PopState.WANDERING;
    }

    // 6) Prevent overlap
    scr_separate_pops();
}
