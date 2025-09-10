extends Node2D

# How instense the shake is.
const INTENSITY = 10

# Duration of the shake.
const DURATION = 1

# the camera for the shakeness
@onready var camera_2D: Camera2D = $Camera2D

# Timer for the jumpscare before transitiong to the game over.
@onready var ice_cube_timer: Timer = $IceCubeTimer

# Ice Cube scare quotes.
@onready var jumpscare1: AudioStreamPlayer = $SFX/Jumpscare1
@onready var jumpscare2: AudioStreamPlayer = $SFX/Jumpscare2

# The list of scare quotes
var ice_cube_jumpscare: Array = []

func _ready() -> void:
	ice_cube_jumpscare = []
	if jumpscare1: ice_cube_jumpscare.append(jumpscare1)
	if jumpscare2: ice_cube_jumpscare.append(jumpscare2)
	
	var random_jumpscare = ice_cube_jumpscare[randi() % ice_cube_jumpscare.size()]
	random_jumpscare.play()

func _process(delta: float) -> void:
	camera_shake()

# For the jumpscare shake.
func camera_shake():
	if not camera_2D: 
		return
	
	# Tween
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Randomize offsets a few times for shake effect
	for i in range(3):
		var ran_offset = Vector2(
			randf_range(-INTENSITY, INTENSITY),
			randf_range(-INTENSITY, INTENSITY)
		)
		tween.tween_property(camera_2D, "offset", ran_offset, DURATION / 3)
		tween.tween_callback(Callable(camera_2D, "updateCameraOffset"))
	
	
# Go to the game over upon timeout.
func _on_ice_cube_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
