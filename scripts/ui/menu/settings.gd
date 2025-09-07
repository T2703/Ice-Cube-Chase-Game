extends Control

# Returns back to the main menu
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
