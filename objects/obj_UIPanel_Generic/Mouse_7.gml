// --- obj_UI_InventoryPanel ---
// Event: Mouse > GUI > Left Released
// Purpose: Stops dragging the panel.
// ============================================================================
#region GUI Left Released Event
if (dragging) { // Only act if a drag was in progress
    // Optional: If you want the release itself to also be "consumed"
    // by the UI system to prevent any other UI element from reacting to this release.
    // if (variable_global_exists("mouse_event_consumed_by_ui")) {
    //     global.mouse_event_consumed_by_ui = true; 
    // }
    dragging = false;
}
#endregion
