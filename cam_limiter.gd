extends Node2D

func get_limit(dir):
	var pos
	match(dir):
		'up':
			pos = $upper.global_position.y
		'down':
			pos = $lower.global_position.y
		'left':
			pos = $left.global_position.x
		'right':
			pos = $right.global_position.x
	return pos
