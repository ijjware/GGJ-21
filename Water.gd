extends Area2D

signal pc_wet()
signal pc_dry()

func _on_Water_body_entered(body):
	if body.name == 'PC':
		emit_signal("pc_wet")
#		print('wet')

func _on_Water_body_exited(body):
	if body.name == 'PC':
		emit_signal("pc_dry")
#		print('dry')
