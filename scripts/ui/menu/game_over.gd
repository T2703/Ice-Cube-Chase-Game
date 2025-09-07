extends Control

# Restarts the game.
func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/loading.tscn")


# Goes back to the main menu.
func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
