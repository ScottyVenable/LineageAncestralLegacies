function scr_get_state_name(_state) {
    switch (_state) {
        case PopState.IDLE:
            return "Idle";
        case PopState.COMMANDED:
            return "Commanded";
        case PopState.WANDERING:
            return "Wandering"
        case PopState.WAITING:
            return "Waiting"
        case PopState.FORAGING:
            return "Foraging"
        default:
            return "Unknown";
    }
}
