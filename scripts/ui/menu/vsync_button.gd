extends CheckButton

func _ready() -> void:
	load_settings()

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Saves the settings.
func _save_setting(value: float) -> void:
	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("display", "vsync", value)
	cfg.save("user://settings.cfg")

# Load up the saved vsync settings.
func load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var vsync_on = cfg.get_value("display", "vsync", true) # default = true
		button_pressed = vsync_on
	else:
		# If no config, default to enabled
		button_pressed = true
