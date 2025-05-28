debug_message("Debug Button Click recognized")
if (global.Debug.Console.Visible){
    global.Debug.Console.Visible = false
    global.set_debug_elements_visibility(false);
    image_index = 0
}

if (global.Debug.Console.Visible = false){
	global.Debug.Console.Enabled = true
    global.set_debug_elements_visibility(true);
    image_index = 1
}
