extends Label

var secs = 0
var mins = 0
#var millis = 0

func _on_Timer_timeout():
#	millis += 1
#	if millis == 100:
#		secs += 1
#		millis = 0
	secs += 1
	if secs == 60:
		mins += 1
		secs = 0
	set_text(get_time())

func get_time():
	var secString
	var minString
	if mins < 10: minString = '0' + mins as String
#	var milliString
#	if millis < 10 : milliString = '0' + millis as String
#	else: milliString = millis as String
	if secs < 10: secString = '0'+secs as String
	else: secString = secs as String
	return (minString + ':' + secString)
	# set_text(mins as String + ':' + secString) # + ':' + milliString) 

func _process(delta):
	var transform = get_tree().get_root().get_canvas_transform()
	var pos = (transform.get_origin() * -1)
	pos = (pos*.4)
	rect_position = pos

func stop():
	$Timer.stop()

func start():
	$Timer.start()

func set_pb(pbmins, pbsecs):
	var timeString = ''
	if pbmins < 10: timeString = '0' + pbmins as String
	else: timeString = pbmins as String
	timeString += ':'
	if pbsecs < 10: timeString += '0' + pbsecs as String
	else: timeString += pbsecs as String
	$PbTimer.set_text(timeString)
