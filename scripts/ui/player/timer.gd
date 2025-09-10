extends Label

# Time in seconds
var elapsed_time = 0.0 

func _process(delta):
	elapsed_time += delta
		
	# Convert into minutes and seconds
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	
	# Format as 0:00.
	text = str(minutes) + ":" + str("%02d" % seconds)
