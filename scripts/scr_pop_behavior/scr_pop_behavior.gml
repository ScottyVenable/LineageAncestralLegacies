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
    }
}
