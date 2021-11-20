extends Node

onready var relics = get_tree().get_nodes_in_group('relics')
var recovery = 0.0
onready var pc = $PC
onready var tutorial = $Tutorial
onready var Results = $EndScreen
onready var txt = $PC/Camera2D/SyndiBox
onready var cam = $PC/Camera2D
onready var camLimiter = $Limiter
onready var held_relics := []
onready var startpos = $Start.global_position
onready var water = $Water

#throw variables
export var throwPow = 10000
export var throwup = -1
export var throwdown = 5

onready var Day = 1
onready var tutorialPhase = 'baby steps'

func _ready():
	limit_camera()
	Global.numRelix = relics.size()

func _on_PC_grab(pos):
	var closest
	var distance
	for node in relics:
		distance = abs(node.global_position.distance_to(pos))
#		print(distance)
		if distance < 10 && not node.is_held:
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
	if event.is_action_pressed("drop_all"):
		lose_relics()
		pc.throwav()
	if event.is_action_pressed("retire"):
		if $Retire.is_visible():
			if Global.daysLeft == 1: game_end()
			else: day_end()

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

func lose_relics():
	for relic in held_relics:
		var force = Vector2(throwdown, throwup)
		if held_relics.size() == 0: return
		match(pc.facingDir):
			'left':
				force *= Vector2(-throwPow, throwPow)
			'right':
				force *= Vector2(throwPow, throwPow)
		relic.hold_switch(false)
		relic.slap(force)
		update_strand()
		pc.remove_box()
	held_relics.clear()

func kill_relics():
	for relic in relics:
		if water.overlaps_body(relic):
			relic.remove_from_group('relics')
			relic.queue_free()
	relics = get_tree().get_nodes_in_group('relics')

func _on_PC_throw():
	var force = Vector2(throwdown, throwup)
	if held_relics.size() == 0:
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
	pc.throwav()
	update_strand()
	pc.remove_box()

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

func limit_camera():
	cam.limit_bottom = camLimiter.get_limit('down')
	cam.limit_top = camLimiter.get_limit('up')
	cam.limit_right = camLimiter.get_limit('right')
	cam.limit_left = camLimiter.get_limit('left')

func _on_DisplayTimer_day_passed():
	if Global.daysLeft == 1:
		game_end()
	day_end()

func day_end():
#	increment day counter
	Day += 1
	Global.daysLeft -= 1
	print(recovery as String + '% relics recovered')
	print('day over')
#	fade out
	pc.thrusters = false
	$AnimationPlayer.play("fade out")
	yield($AnimationPlayer, "animation_finished")
	
#	drop all relix
	lose_relics()
#	reset to start pos
	
#	kill all relix underwater
	yield(get_tree().create_timer(1, false), "timeout")
	kill_relics()
#	swap out water
	water.change_water(Day)
#	reset timer
	$DisplayTimer.stop()
	$DisplayTimer.secs = 180
	$DisplayTimer.get_time()
	yield(get_tree().create_timer(1, false), "timeout")
#	fade in
	Results.global_position = startpos
	pc.global_position = startpos
	$AnimationPlayer.play_backwards("fade out")
	yield($AnimationPlayer, "animation_finished")
	Results.end_screen()

func _on_Chest_body_entered(body):
	if body.is_in_group('relics'):
		$deposit.play()
#		print('box it')
		Global.relixRecovered += 1
		recovery = floor((Global.relixRecovered as float/Global.numRelix as float)*100)
		body.remove_from_group('relics')
		body.queue_free()
		relics = get_tree().get_nodes_in_group('relics')

func _on_EndScreen_finished():
#	timer start
	yield(get_tree().create_timer(2, false), "timeout")
	Results.global_position = Vector2()
	$DisplayTimer.start()
	pc.thrusters = true

func game_end():
	get_tree().change_scene("res://GameOver.tscn")

func _on_Camper_body_entered(body):
	if body == pc:
		print('camp')
		$Retire.set_visible(true)

func _on_Camper_body_exited(body):
	if body == pc:
		$Retire.set_visible(false)
