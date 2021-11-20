extends Label

var secs = 160

signal day_passed

func _on_Timer_timeout():
	secs -= 1
	if secs > 0:
		Global.totalSecs += 1
	get_time()
	if secs == 0:
		stop()
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
