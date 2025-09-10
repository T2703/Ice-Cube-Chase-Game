extends Node

# Enum for clarity
enum WindowMode { FULLSCREEN, WINDOWED, BORDERLESS }

# Stored values defaults to fullscreen.
var window_mode: WindowMode = WindowMode.FULLSCREEN

# Load the saved settings when the game starts.
func _ready() -> void:
	load_settings()
	apply_settings()
	

# Sets the window mode.
func set_window_mode(mode: WindowMode) -> void:
	window_mode = mode
	_apply_window_mode()
	save_settings()

# Gets and returns thew window mode.
func get_window_mode() -> WindowMode:
	return window_mode

# Apply which window to select.
func _apply_window_mode() -> void:
	# Always clear borderless flag first
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	match window_mode:
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280, 720))

		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_position(Vector2i(0, 0))

func apply_settings() -> void:
	_apply_window_mode()

# Saves the settings
func save_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("display", "window_mode", int(window_mode))
	cfg.save("user://settings.cfg")

# Loads up the settings
func load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		window_mode = cfg.get_value("display", "window_mode", WindowMode.WINDOWED)

func apply_resolution() -> void:
	var cfg = ConfigFile.new()
	var mode = DisplayServer.window_get_mode()
	if cfg.load("user://settings.cfg") == OK:
		var saved_res: Vector2i = cfg.get_value("display", "resolution", Vector2i(1280, 720))
		DisplayServer.window_set_mode(mode)
		DisplayServer.window_set_size(saved_res)
		DisplayServer.window_set_position(
			(DisplayServer.screen_get_size() - saved_res) / 2
		)
