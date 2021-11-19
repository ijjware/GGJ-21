extends Label

var secs = 100

signal day_passed

func _on_Timer_timeout():
	secs -= 1
	get_time()
	if secs == 0:
		emit_signal("day_passed")

func get_time():
	var secString = secs as String
	if secs < 100: secString = '0'+secString
	if secs < 10: secString = '0'+secString
	else: secString = secs as String
	set_text(secString)

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
