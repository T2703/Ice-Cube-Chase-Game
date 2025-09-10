extends Control

# Best time recorded.
@onready var best_time: Label = $BestTime 

func _ready():
	var total_seconds = int(GlobalTimer.survival_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	best_time.text = "You survived for %d:%02d" % [minutes, seconds]

# Restarts the game.
func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/loading.tscn")


# Goes back to the main menu.
func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
