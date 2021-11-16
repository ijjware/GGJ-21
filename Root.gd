extends Node

onready var relics = get_tree().get_nodes_in_group('relics')
onready var pc = $PC
onready var tutorial = $Tutorial
onready var txt = $PC/Camera2D/SyndiBox
onready var held_relics := []

#throw variables
export var throwPow = 10000
export var throwup = -1
export var throwdown = 5

onready var tutorialPhase = 'baby steps'

func _on_PC_grab(pos):
	var closest
	var distance
	for node in relics:
		distance = abs(node.global_position.distance_to(pos))
#		print(distance)
		if distance < 30 && not node.is_held:
			if tutorialPhase == 'pickup':
				txt.picked_up()
				tutorialPhase = 'bridge1'
				tutorial.enable_zone('overbridge')
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
#		print('empty handed')
		return
	if not pc.sightline.is_colliding():
		#	relic in index 0 is dropped		
		drop(0)
#		print('drop')

func drop(index):
	var relic = held_relics[index]
	held_relics.remove(index)
#   node is removed from list of held relics
#   node is placed in front of player
	relic.hold_switch(false)
	relic.global_position = pc.global_position
	relic.animate('rest')
	update_strand()
	pc.remove_box()

func _on_PC_throw():
	var force = Vector2(throwdown, throwup)
	if held_relics.size() == 0:
#		print('empty handed')
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
#	print('throw')

func update_strand():
#	updates the indices + positions of all held relics
	for relic in held_relics:
		var index = held_relics.find(relic)
		relic.index = index

func _on_Water_pc_dry():
	pc.move_terrain(false)
#	print('root dry')

func _on_Water_pc_wet():
	pc.move_terrain(true)
#	print('root wet')

func _on_SyndiBox_first_steps():
	tutorial.baby_steps()
	tutorialPhase = 'pickup'

# TODO: finish up tut sequence
func _on_zones_body_entered(body):
	if body == pc:
		if tutorialPhase == 'pickup':
			txt.pickup()
			tutorial.disable_zone('pickup')
		if tutorialPhase == 'bridge1':
#			print('bridge')
			tutorial.bridge1_break()
			tutorial.disable_zone('overbridge')
			yield(get_tree().create_timer(2, false), "timeout")
			txt.first_fall()
		if tutorialPhase == 'bridge2':
#			print('2 break')
			tutorial.bridge2_break()
			tutorial.disable_zone('overbridge2')
			yield(get_tree().create_timer(2, false), "timeout")
			txt.second_fall()
			pc.thrusters = true
			tutorial.queue_free()

func _on_SyndiBox_second_fall():
	tutorialPhase = 'bridge2'
