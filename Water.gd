extends Area2D

signal pc_wet()
signal pc_dry()

func _on_Water_body_entered(body):
	if body.name == 'PC':
		emit_signal("pc_wet")

func _on_Water_body_exited(body):
	if body.name == 'PC':
		emit_signal("pc_dry")

func change_water(day):
	match(day):
		2:
			$day1.set_deferred('disabled', true)
			$day1.set_visible(false)
			$day2.set_deferred('disabled', false)
			$day2.set_visible(true)
		3:
			$day2.set_deferred('disabled', true)
			$day3.set_deferred('disabled', false)
