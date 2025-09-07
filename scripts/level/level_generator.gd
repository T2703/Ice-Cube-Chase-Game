extends Node2D

# This stuff was pretty much taken from this 16bit dev guy on a tutorial on how to 
# Do this stuff, this crap is not fun when I first did it so I uh use tutorial to help me lol

# The tile map for the level.
@export var tilemap: TileMapLayer

# The player itself.
@export var player: CharacterBody2D

# The cube itself.
@export var icecube: CharacterBody2D

# Width of the level.
const LEVEL_WIDTH = 120

# Height of the level.
const LEVEL_HEIGHT = 120

# The type of tile such as floors or walls.
enum TileType { EMPTY, FLOOR, WALL }

# The grid of the level.
var level_grid = []

func _ready() -> void:
	create_level()

# Generates the level
func generate_level():
	# Start off empty.
	level_grid = []
	
	# For each row/height in the level, append an empty array.
	# This sizes up the grid.
	for y in LEVEL_HEIGHT:
		level_grid.append([])
		
		# For each column/width append the empty type to that row array.
		for x in LEVEL_WIDTH:
			level_grid[y].append(TileType.EMPTY)
		
	# Stores every room's rect value
	var rooms: Array[Rect2] = []
	var max_attempts = 100
	var tries = 0
	
	# Try to generate 10-15 rooms with 100 attempts
	while rooms.size() < randi_range(10, 15) and tries < max_attempts:
		# Width, height, x and y positions.
		var w = randi_range(8, 16)
		var h = randi_range(8, 16)
		var x = randi_range(1, LEVEL_WIDTH - w - 1)
		var y = randi_range(1, LEVEL_WIDTH - h - 1)
		var room = Rect2(x, y, w, h)
		
		var overlaps = false
		
		# Go through the rooms to check if they overlap
		for other in rooms:
			if room.grow(1).intersects(other):
				overlaps = true
				break
		
		# No overlaps means we add/append the room in.
		if not overlaps:
			rooms.append(room)
			for iy in range(y, y + h):
				for ix in range(x, x + w):
					level_grid[iy][ix] = TileType.FLOOR
			
			# Get the last two rooms as previous and current.
			if rooms.size() > 1:
				var previous = rooms[rooms.size() - 2].get_center()
				var current = room.get_center()
				carve_corridor(previous, current)
		
		tries += 1
		ensure_connectivity(rooms)
	
	return rooms
		
# Renders the level by clearing any previously drawn tiles.
func render_level():
	tilemap.clear()
	
	# Loop over every tile in the level.
	for y in range(LEVEL_HEIGHT):
		for x in range(LEVEL_WIDTH):
			var tile = level_grid[y][x]
			
			# Match the tile and set the tiles with its matching type.
			match tile:
				TileType.FLOOR: tilemap.set_cell(Vector2(x, y), 0, Vector2i(3, 1))
				TileType.WALL: tilemap.set_cell(Vector2(x, y), 0, Vector2i(1, 1))

# Carves the corridor. L shape buildings.
func carve_corridor(from: Vector2, to: Vector2, width: int = 2):
	var min_width = -width / 2
	var max_width = width / 2
	
	# Picks randomly between the L shape.
	if randf() < 0.5:
		# Horizontal corridor
		for x in range(min(from.x, to.x), max(from.x, to.x) + 1):
			for offset in range(min_width, max_width + 1):
				var y = from.y + offset
				if is_in_bounds(x, y):
					level_grid[y][x] = TileType.FLOOR
		
		# Vertical corridor
		for y in range(min(from.y, to.y), max(from.y, to.y) + 1):
			for offset in range(min_width, max_width + 1):
				var x = from.x + offset
				if is_in_bounds(x, y):
					level_grid[y][x] = TileType.FLOOR
	else:
		# Vertical corridor
		for y in range(min(from.y, to.y), max(from.y, to.y) + 1):
			for offset in range(min_width, max_width + 1):
				var x = from.x + offset
				if is_in_bounds(x, y):
					level_grid[y][x] = TileType.FLOOR
 		
		# Horizontal corridor
		for x in range(min(from.x, to.x), max(from.x, to.x) + 1):
			for offset in range(min_width, max_width + 1):
				var y = to.y + offset
				if is_in_bounds(x, y):
					level_grid[y][x] = TileType.FLOOR

# Check if its in the bounds of the level.
func is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >=0 and x < LEVEL_WIDTH and y < LEVEL_HEIGHT
	
# This adds the walls.
func add_walls():
	# Loop through each tile in the level.
		for y in range(LEVEL_HEIGHT):
			for x in range(LEVEL_WIDTH):
				
				# Get the neighboring coords if pass.
				if level_grid[y][x] == TileType.FLOOR:
					for dy in range(-1, 2):
						for dx in range(-1, 2):
							var nx = x + dx
							var ny = y + dy
							
							# Any neighboring tile will be set to a wall tile.
							if nx >= 0 and ny >= 0 and nx < LEVEL_WIDTH and ny < LEVEL_HEIGHT:
								if level_grid[ny][nx] == TileType.EMPTY:
									level_grid[ny][nx] = TileType.WALL

# Spawns the player in a random location and ice cube.
func spawn_player(rooms: Array[Rect2]):
	var min_distance = 1000.0
	var spawn_player_pos = rooms.pick_random().get_center() * 16
	var ice_cube_pos = rooms.pick_random().get_center() * 16
	
	print(spawn_player_pos, ice_cube_pos)
	
	# Make sure the player does not spawn too close to ice cube.
	while spawn_player_pos.distance_to(ice_cube_pos) < min_distance:
		ice_cube_pos = rooms.pick_random().get_center() * 16
	
	player.position = spawn_player_pos
	icecube.position = ice_cube_pos
	
	# Setup partrol points
	var patrols: Array[Vector2] = []
	for r in rooms:
		patrols.append(r.get_center() * 16)

	icecube.set_patrol_points(patrols)

# Hopefully this ensures that the rooms WILL connect otherwise this generation thing
# is stupoid poo poo.
func ensure_connectivity(rooms: Array[Rect2]):
	if rooms.is_empty():
		return
	
	var connected = [rooms[0]]
	var disconnected = rooms.slice(1, rooms.size())
	
	while not disconnected.is_empty():
		var room_to_connect = disconnected.pop_front()
		var closest_room = null
		var closest_dist = INF
		
		# Find the nearest already connected room
		for c in connected:
			var dist = room_to_connect.get_center().distance_to(c.get_center())
			if dist < closest_dist:
				closest_dist = dist
				closest_room = c
		
		# Carve a corridor to connect it
		carve_corridor(room_to_connect.get_center(), closest_room.get_center())
		connected.append(room_to_connect)
	
# Create the level.
func create_level():
	spawn_player(generate_level())
	add_walls()
	render_level()
