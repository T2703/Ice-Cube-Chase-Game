extends CharacterBody2D

# Speed of the player movement.
const SPEED = 200

# Running speed.
const RUNNING_SPEED = 300

# The dashing speed.
const DASH_SPEED = 500

# Accleration of the player.
const ACCELERATION = 0.2

# The dash cost.
const DASH_COST = 30

# How long the dash lasts.
var DASH_DURATION = 0.2

# Movement friction for sliding and moving.
const FRICTION = 1

# How far the player can look ahead.
const LOOK_AHEAD_DISTANCE = 120

# Stamina timer so it's not decreasing the stamina too fast.
@onready var stamina_timer: Timer = $MovementTimers/StaminaTimer

# Stamina regeneration.
@onready var stamina_regen_timer: Timer = $MovementTimers/StaminaRegenTimer

# The dash timer.
@onready var dash_timer: Timer = $MovementTimers/DashTimer

# How long the player has i-frames (title card).
@onready var invicinible_timer: Timer = $MovementTimers/InvicinibleTimer

# Hitbox of the player.
@onready var playerHitbox: Area2D = $PlayerHitbox

# The footsteps sound effect.
@onready var footsteps: AudioStreamPlayer2D = $SFX/Footsteps

# The footsteps sound effect timer.
@onready var footsteps_timer: Timer = $SFX/FootstepsTimer

# Stamina of the player
var stamina = 100

# The current speed of the player.
var current_speed = SPEED

# The current direction of the dash.
var dash_direction = Vector2.ZERO

# Check if the player is sprinting.
var is_sprinting = false

# Check if the player is dashing.
var is_dashing = false

# Checks if ice cube has touched the player thus resulting in death. 
# AMAZON!!!!!
var is_dead = false

# The direction of the player from getting the input.
var direction: Vector2 = Vector2.ZERO

# Offset look
var look_offset: Vector2 = Vector2.ZERO

# You can do the offset shaker huh.
var shake_offset: Vector2 = Vector2.ZERO

# The survival time for the player.
var survival_time = 0.0

# Gets the input of the player.
func get_input():
	# Movement
	var input = Input.get_vector("left", "right", "up", "down")
		
	return input

# The run boy run mechanic for the player or sprinting. Must have for aliens.
func run():
	# If not sprinting then set the sprint to true and start the timer and when only moving.
	if direction.length() > 0:  
		if not is_sprinting:
			stamina_timer.start()
			is_sprinting = true
		current_speed = RUNNING_SPEED
	else:
		stop_run()

# Return to walkiing.
func stop_run():
	current_speed = SPEED
	is_sprinting = false 
	
	# stop if needed.
	if not stamina_regen_timer.is_stopped():
		stamina_regen_timer.stop()
	stamina_regen_timer.start()

# Dashing movement, this is like a dodge.
func dash():
	if not is_dashing and stamina >= DASH_COST:
		# Decrease stamina
		stamina -= DASH_COST
		
		# Get the dash direction.
		dash_direction = direction.normalized()
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.RIGHT.rotated(rotation)
			
		
		# Disable the hitbox
		playerHitbox.monitoring = false
		playerHitbox.monitorable = false
		invicinible_timer.start()
		
		# Set the dash state.
		is_dashing = true
		current_speed = DASH_SPEED
		dash_timer.start(DASH_DURATION)
		stamina_regen_timer.start()

# This function updates the camera position, it makes the player look ahead.
func update_camera_position():
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	look_offset = mouse_direction * LOOK_AHEAD_DISTANCE
	update_camera_offset()

# Reset the camera postion back to the player.
func reset_camera_position(delta):
	look_offset = look_offset.lerp(Vector2.ZERO, delta * 10)
	update_camera_offset()

# Combines the offsets.
func update_camera_offset():
	$PlayerCamera.offset = look_offset + shake_offset
	
# Anything related to the movement
func _physics_process(delta: float) -> void:
	# Look around from mouse position.
	look_at(get_global_mouse_position())
	
	# Movement with the physics
	direction = get_input()
	
	# If dashing ignore the acceleration and friction.
	if is_dashing:
		velocity = dash_direction * current_speed
	# Regular movement
	else:
		if direction.length() > 0:
			velocity = velocity.lerp(direction.normalized() * current_speed, ACCELERATION)
			if footsteps_timer.is_stopped():
				footsteps_timer.start()
		else:
			velocity = velocity.lerp(Vector2.ZERO, FRICTION)
			if not footsteps_timer.is_stopped():
				footsteps_timer.stop()
		
	move_and_slide()

# Anything unrelated to the movement
func _process(delta: float) -> void:
	if not is_dead:
		survival_time += delta
		
	# Sprinting/running when shitfing.
	if not is_dashing:
		if Input.is_action_pressed("shift") and stamina > 0 and direction.length() > 0: 
			run()
		else:
			if is_sprinting:
				stop_run()
	
	# Dashing
	if Input.is_action_just_pressed("space"):
		dash()
		
	# For looking up ahead.
	if Input.is_action_pressed("rclick"): 
		update_camera_position()
	elif !Input.is_action_pressed("rclick"): 
		reset_camera_position(delta)

# Decrease the stamina from the player for everytime they run.
func _on_stamina_timer_timeout() -> void:
	# Run when stamina and stop when none.
	if is_sprinting and stamina > 0 and velocity.length() > 0:
		stamina -= 1
		if stamina <= 0:
			stop_run()

# Giveth the stamina back this is our regen.
func _on_stamina_regen_timer_timeout() -> void:
	# Return but only when the player isn't sprinting.
	# And when the stamina is less than 100.
	if (not is_sprinting or direction.length() == 0) and stamina < 100:
		stamina += 1
		stamina = clamp(stamina, 0, 100)
		
# End the dash
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	current_speed = SPEED

# Play the jumpscare when ice cube touches you.
func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Jumpscare":
		GlobalTimer.survival_time = survival_time
		is_dead = true
		get_tree().change_scene_to_file("res://scenes/ice cube/ice_cube_jumpscare.tscn")

# Renable the hitbox when done with the dash i-frame timer thing.
func _on_invicinible_timer_timeout() -> void:
	playerHitbox.monitoring = true
	playerHitbox.monitorable = true

# Play the foot step sound.
func _on_footsteps_timer_timeout() -> void:
	footsteps.play()
