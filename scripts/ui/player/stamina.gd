extends Label

# Player reference
var playerRef

func _process(delta):
	playerRef = get_parent().get_parent().get_parent()
	text = "Stamina:" + str(playerRef.stamina)
