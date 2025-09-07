extends Node2D

# Start up the loading screen.
func _ready() -> void:
		# Async load.
		ResourceLoader.load_threaded_request("res://scenes/level/main_level.tscn")
		
		# Poll until finished.
		while true:
			var progress: Array = []
			var status = ResourceLoader.load_threaded_get_status("res://scenes/level/main_level.tscn", progress)
		
			# End loop once loaded.
			if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				break
				
			await get_tree().process_frame

		# Load new level
		var nextLevelPacked = ResourceLoader.load_threaded_get("res://scenes/level/main_level.tscn")
		get_tree().call_deferred("change_scene_to_packed", nextLevelPacked)
