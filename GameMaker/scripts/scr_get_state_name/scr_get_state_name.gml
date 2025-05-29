function scr_get_state_name(_state) {
    switch (_state) {
        case EntityState.IDLE:
            return "Idle";
        case EntityState.COMMANDED:
            return "Moving";
        case EntityState.WANDERING:
            return "Wandering"
        case EntityState.WAITING:
            return "Waiting"
        case EntityState.FORAGING:
            return "Foraging"
		case EntityState.HAULING:
			return "Hauling"
        default:
            return "Unknown";
    }
}
