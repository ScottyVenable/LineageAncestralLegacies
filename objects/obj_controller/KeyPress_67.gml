// Only the currently selected pop goes into WAITING
with (obj_pop) if (selected) {
    state       = PopState.WAITING;
    is_waiting  = true;
    idle_timer  = 0;
    has_arrived = false;    
}

else{
    debug_event("Not Waiting")
}
