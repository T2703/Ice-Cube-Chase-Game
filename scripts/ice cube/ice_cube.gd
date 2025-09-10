extends CharacterBody2D

# Detection radius
const DETECTION_RADIUS = 200

# Speed of ice cube
const SPEED = 200

# Patrol Speed of ice cube
const PATROL_SPEED = 120

# The memory timer.
const CHASE_MEMORY = 2.0

# The time he has been for being stuck.
const STUCK_TIMER = 0.3

# The time it takes to search.
const SEARCH_TIMER = 5.0

# The navigation that Ice Cube uses for patroling/moving.
@onready var nav_agent: NavigationAgent2D = $NavigationAgent

# This gets the player from the scene/level.
@onready var player = get_tree().get_first_node_in_group("player").get_parent()

# The spotted sound effect.
@onready var spotted: AudioStreamPlayer2D = $SFX/Spotted

# The time he has since seen you.
var time_since_seen = 0.0

# Patrol points.
var patrol_points = []

# The patrol index.
var patrol_index = 0

# AI states.
enum {PATROL, CHASE, SEARCH}

# Current state.
var state = PATROL

# ice cube waiting for the next move.
var waiting = false

# The current speed of the cube.
var current_speed = PATROL_SPEED

# The time he has spent being stucked.
var stuck_time = 0.0

# Last position.
var last_position = Vector2.ZERO

# Last known position of the player for searching.
var last_seen_position: Vector2 = Vector2.ZERO

# Checks if the navmesh is ready.
var nav_ready = false

# How long the search is.
var search_elasped = 0.0

# Ready init.
func _ready() -> void:
	nav_agent.radius = 12
	nav_agent.avoidance_enabled = true 
	NavigationServer2D.map_changed.connect(_on_map_changed)
	
	# Wait till the nav map is valid.
	var map_rid = nav_agent.get_navigation_map()
	if map_rid.is_valid():
		# Safe to set target
		set_patrol_target()
		nav_ready = true
	# Not ready yet so sync.
	else:
		NavigationServer2D.map_changed.connect(_on_map_changed)

# Movment process
func _physics_process(delta: float) -> void:
	match state:
		PATROL:
			patrol_behavior()
			check_player_detection()
			current_speed = PATROL_SPEED
		CHASE:
			chase_behavior(delta)
			current_speed = SPEED
		SEARCH:
			search_behavior(delta)
			check_player_detection() 
			current_speed = PATROL_SPEED
	
	# Ice Cube on the move.
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var target = nav_agent.get_next_path_position()
		var direction = (target - global_position).normalized()
		velocity = direction * current_speed
		move_and_slide()
	
	# At the end of _physics_process(delta)
	if global_position.distance_to(last_position) < 1.0:
		stuck_time += delta
		if stuck_time >= STUCK_TIMER:
			if state == CHASE:
				# Switch to SEARCH to avoid getting stuck forever
				state = SEARCH
				nav_agent.target_position = last_seen_position
			elif state == PATROL:
				# Go to next patrol point if stuck
				patrol_index = (patrol_index + 1) % patrol_points.size()
				nav_agent.target_position = patrol_points[patrol_index]
			stuck_time = 0.0
	else:
		stuck_time = 0.0

	last_position = global_position

# This exists idk.
func _on_map_changed(_map_rid):
	# Only set target if it has been updated.
	if _map_rid == nav_agent.get_navigation_map():
		nav_ready = true
		set_patrol_target()
	
# Sets the target to patrol.
func set_patrol_target():
	if patrol_points.is_empty():
		return
	nav_agent.target_position = patrol_points[patrol_index]
	
# Patrolling functionality.
func patrol_behavior():
	if not nav_ready:
		return
		
	# Once done...
	if nav_agent.is_navigation_finished():
		# Go on to the next point Cube.
		patrol_index = (patrol_index + 1) % patrol_points.size()
		nav_agent.target_position = patrol_points[patrol_index]

# Get a random point wihtin the navigation polygon.
func get_random_patrol_point() -> Vector2:
	if not nav_ready:
		return global_position
		
	var map_rid = nav_agent.get_navigation_map()
	var regions = NavigationServer2D.map_get_regions(map_rid)
	if map_rid.is_valid():
		if regions.size() > 0:
			var region_rid = regions[0]
			return NavigationServer2D.region_get_random_point(region_rid, 0, 1)
	
	# Fallback just incase.
	return global_position

# The chasing functionality (JOJO PART 4)
func chase_behavior(delta):
	# If player exists or is there then CHASE.
	if player:
		if global_position.distance_to(player.global_position) < DETECTION_RADIUS and can_see_player():
			# Still in sight.
			time_since_seen = 0.0
			last_seen_position = player.global_position
			nav_agent.target_position = player.global_position
		else:
			time_since_seen += delta
			state = SEARCH
			nav_agent.target_position = last_seen_position
			#if time_since_seen >= CHASE_MEMORY:
				# Give up chase and return to patrol
				#state = SEARCH
				#nav_agent.target_position = last_seen_position

# Searches the player by going to the last known location.
func search_behavior(delta):
	if nav_agent.is_navigation_finished():
		search_elasped += delta
		print("SEARCH")
		if search_elasped >= SEARCH_TIMER:
			# Give up after searching
			search_elasped = 0.0
			state = PATROL
			set_patrol_target()

# Checks if the player has been detected.
func check_player_detection():
	if player and global_position.distance_to(player.global_position) < DETECTION_RADIUS:
		if can_see_player():
			if state != CHASE:
				spotted.play()
			state = CHASE
			time_since_seen = 0.0
			last_seen_position = player.global_position
	else:
		state = PATROL

# Can check if Ice Cube sees the player.
func can_see_player() -> bool:
	if not player:
		print("Player Not Found")
		return false
	
	# Create the space state for detection.
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	
	# Exclude himself so he doesn't see himself.
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	# If the ray hits nothing or hits the player then we can see YOU.
	if result.is_empty() or result.collider == player:
		return true
	
	# False if none of the above.
	return false

# Sets the patrol points of the level
func set_patrol_points(points: Array[Vector2]):
	patrol_points = points
	patrol_index = 0
	
	if nav_ready and not patrol_points.is_empty():
		nav_agent.target_position = patrol_points[0]
