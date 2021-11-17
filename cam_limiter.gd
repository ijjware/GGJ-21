extends Node2D

func get_limit(dir):
	var pos
	match(dir):
		'up':
			pos = $upper.global_position
		'down':
			pos = $lower.global_position
		'left':
			pos = $left.global_position
		'right':
			pos = $right.global_position
	return pos
