extends OptionButton

# The window types/modes.
enum WindowMode { FULLSCREEN, WINDOWED, BORDERLESS }

func _ready() -> void:
	# Populate the dropdown.
	clear()
	add_item("Fullscreen", AutoLoadSettings.WindowMode.FULLSCREEN)
	add_item("Windowed", AutoLoadSettings.WindowMode.WINDOWED)
	add_item("Borderless", AutoLoadSettings.WindowMode.BORDERLESS)
	
	# Select the current window mode
	select(AutoLoadSettings.get_window_mode())

	# Connect selection
	connect("item_selected", Callable(self, "_on_item_selected"))

# The item selected.
func _on_item_selected(index: int) -> void:
	AutoLoadSettings.set_window_mode(index)

# This sets the window mode.
func set_window_mode(mode: WindowMode) -> void:
	# Reset borderless flag in case it was set before
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	match mode:
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280, 720)) # change to your default

		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_position(Vector2i(0, 0))

# Gets the current window mode.
func _get_current_mode() -> int:
	var mode = DisplayServer.window_get_mode()
	var borderless = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)

	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return WindowMode.FULLSCREEN
	elif borderless:
		return WindowMode.BORDERLESS
	else:
		return WindowMode.WINDOWED
