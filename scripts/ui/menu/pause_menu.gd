extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
func _process(_delta): 
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused

# Resumes the game.
func _on_resume_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused

# Quit to main menu.
func _on_quit_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")

# Restarts the game.
func _on_restart_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://scenes/ui/loading.tscn")
