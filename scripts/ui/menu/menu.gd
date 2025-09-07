extends Control

# Plays the game.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/loading.tscn")

# Quits the game.
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Goes to the settings page.
func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn")
