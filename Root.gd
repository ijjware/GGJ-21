extends Node

onready var relics = get_tree().get_nodes_in_group('relics')
onready var pc = $PC
onready var held_relics := []

export var throwPow = 10000
export var throwup = -1
export var throwdown = 5

#onready var relic_index = 0

func _on_PC_grab(pos):
	var closest
	var distance
	for node in relics:
		distance = abs(node.global_position.distance_to(pos))
#		print(distance)
		if distance < 30 && not node.is_held:
#			TODO: sort valid relics by distance and only grab closest relic
			held_relics.insert(0, node)
			node.link = pc
			node.hold_switch(true)
#			print($PC.head_pos())
			node.animate('float')
			update_strand()
			pc.add_box()
			return

func _unhandled_input(event):
	if event.is_action_pressed('reset'):
		get_tree().reload_current_scene()
	if event.is_action_pressed("break"):
		pass

func _on_PC_drop():
	if held_relics.size() == 0:
		print('empty handed')
		return
	if not pc.sightline.is_colliding():
		#	relic in index 0 is dropped		
		drop(0)
		print('drop')

func drop(index):
	var relic = held_relics[index]
	held_relics.remove(index)
#   node is removed from list of held relics
#   node is placed in front of player
	relic.hold_switch(false)
	relic.global_position = pc.get_in_front()
	relic.animate('rest')
	update_strand()
	pc.remove_box()

func _on_PC_throw():
	var force = Vector2(throwdown, throwup)
	if held_relics.size() == 0:
		print('empty handed')
		return
	var relic = held_relics[0]
	held_relics.remove(0)
	match(pc.facingDir):
		'left':
			force *= Vector2(-throwPow, throwPow)
		'right':
			force *= Vector2(throwPow, throwPow)
	relic.hold_switch(false)
	relic.slap(force)
	update_strand()
	pc.remove_box()
	print('throw')
	pass # Replace with function body.

func update_strand():
#	updates the indices + positions of all held relics
	for relic in held_relics:
		var index = held_relics.find(relic)
		relic.index = index
