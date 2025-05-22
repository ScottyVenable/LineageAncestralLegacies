function scr_pop_behavior() {
    switch (state) {
        case PopState.IDLE:
            scr_pop_idle();
            break;
        case PopState.WANDERING:
            scr_pop_wandering();
            break;
        case PopState.COMMANDED:
            scr_pop_commanded();
            break;
        case PopState.WAITING:
            scr_pop_waiting();  // new handler
            break;
        case PopState.FORAGING:   
            scr_pop_foraging();   
            break;  // ← new
		case PopState.HAULING:
		    if (script_exists(scr_pop_hauling)) {
		        scr_pop_hauling();
		    } else {
		        show_debug_message_once($"ERROR: scr_pop_hauling script missing for pop {id}!");
		        state = PopState.IDLE; // Fallback
		    }
		    break;
    }
}
