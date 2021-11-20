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
			$watah1.set_visible(false)
			$day2.set_deferred('disabled', false)
			$watah2.set_visible(true)
		3:
			$day2.set_deferred('disabled', true)
			$watah2.set_visible(false)
			$day3.set_deferred('disabled', false)
			$watah3.set_visible(true)
		4:
			$day3.set_deferred('disabled', true)
			$watah3.set_visible(false)
			$day4.set_deferred('disabled', false)
			$watah4.set_visible(true)
		5:
			$day4.set_deferred('disabled', true)
			$watah4.set_visible(false)
			$day5.set_deferred('disabled', false)
			$watah5.set_visible(true)
