extends HSlider

# The name of the bus audio.
@export var bus_name: String

# The index of the bus audio.
@export var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	load_settings()
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

# changes the volume of the sound music thing.
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	_save_setting(value)
	

# Saves the settings.
func _save_setting(value: float) -> void:
	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg") 
	cfg.set_value("audio", bus_name, value)
	cfg.save("user://settings.cfg")

# Load up the saved volume settings.
func load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		if cfg.has_section_key("audio", bus_name):
			var saved_linear = cfg.get_value("audio", bus_name, value)
			value = saved_linear
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	else:
		value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
