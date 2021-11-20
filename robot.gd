extends KinematicBody2D

export (PackedScene) var Box

var toss = preload('res://sounds/Jump.wav')
var jump = preload('res://sounds/jamp.wav')
var borble = preload('res://sounds/bubble.wav')

var vertical_speed := 0.0
var jump_counter = 0
var thrusters = false
var bonkHeight = -7
onready var possessor = $possessives
onready var walker = $walk
onready var jamper = $jamp
onready var tree = get_tree()
onready var eyes = $Sight
onready var ani = $Ani

#physics vars
export var vJump = 600
export var gravity = 200.0
export var sWalk = 200

#minimum physics variables
export var minWalk = 20
export var minGrav = 200
export var minJump = 100
var velocity := Vector2()

#water physics increments
export var gravInc = 300
export var jumpInc = 200
export var walkInc = 50

#crate physics increments
export var vInc = 100
export var sInc = 30
export var vIncWet = 20
export var sIncWet = 10

onready var sightDist = 6
onready var facingDir = $Head.get_animation()
onready var sightline = $Sight
onready var first_pos = Vector2(-1, -8)
var pos_gap = Vector2(0, -12)
var relicBoxes = []
var underwater = false

signal grab(pos)
signal drop()
signal throw()

func _ready():
	thrusters = true
#	$ChargeTimer.wait_time = chargeTime
#	$DepleteTimer.wait_time = depleteTime
#	solarPower = powerMax
	pass

func head_pos(index):
	var pos = global_position
	pos += first_pos
	if index > 0:
		pos += (pos_gap * index)
#		print(pos_gap * index)
	return pos



func add_box():
	var box = Box.instance()
	add_child(box)
	relicBoxes.append(box)
	box.global_position = head_pos(relicBoxes.size() - 1)
	move_bonkers()
	vJump -= vInc
	sWalk -= sInc
	if underwater:
		vJump -= vIncWet
		sWalk -= sIncWet

func remove_box():
	var nix = relicBoxes.pop_back()
	if nix: nix.queue_free()
	move_bonkers()
	vJump += vInc
	sWalk += sInc
	if underwater:
		vJump += vIncWet
		sWalk += sIncWet

func get_in_front():
	var pos = global_position
	match(facingDir):
		'left':
			pos += Vector2(-10, 0)
			pass
		'right':
			pos += Vector2(10, 0)
	return pos

func seeing(pos):
	sightline.cast_to = pos
	sightline.force_raycast_update()

func _physics_process(delta):
	if not thrusters: return
	if Input.is_action_pressed("right"):
		if sWalk < minWalk: velocity.x = minWalk
		else: velocity.x = sWalk
		facingDir = 'right'
		seeing(Vector2(sightDist-.5, 0))
		ani.play(facingDir)
		if detect_floors(): walkwav()
	elif Input.is_action_pressed("left"):
		if sWalk < minWalk: velocity.x = -minWalk
		else: velocity.x = -sWalk
		facingDir = 'left'
		seeing(Vector2(-(sightDist+ .5) , 0))
		ani.play(facingDir)
		if detect_floors(): walkwav()
	else: 
		velocity.x = 0
#		stop_walk()
	vertical_movement(delta)
	move_and_slide(velocity, Vector2(0, -1))
	if Input.is_action_just_pressed("pick_up"):
		emit_signal("grab", global_position)
	if Input.is_action_just_pressed("drop"):
		if Input.is_action_pressed("down"):
			emit_signal("drop")
		else: emit_signal("throw")

func disable_plat():
	tree.call_group('platDetectors', 'set_enabled', false)
	yield(get_tree().create_timer(.5, false), "timeout")
	tree.call_group('platDetectors', 'set_enabled', true)

func vertical_movement(delta):
	if gravity < minGrav : velocity.y += delta * minGrav
	else: velocity.y += delta * gravity
	if detect_floors():
		jump_counter = 0
		if velocity.y > 0: velocity.y = 0
	if Input.is_action_just_pressed("jump") && thrusters: # && solarPower > 0:
		if jump_counter < 2 || not is_jump_limited():
			jumpwav()
			disable_plat()
			if vJump < minJump: velocity.y = -minJump
			else: velocity.y = -vJump
			if is_jump_limited():
				jump_counter +=1
#			else: jump_counter = 0
	
	if is_bonking():
		if gravity < minGrav : velocity.y += delta * minGrav
		else: velocity.y += delta * gravity

func move_terrain(wet):
	var boxes = relicBoxes.size()
	if wet:
		underwater = true
		boxes *= -1
		wet_pc(-1)
	else:
		underwater = false
		wet_pc(1)
	vJump += boxes * vIncWet
	sWalk += boxes * sIncWet

func is_jump_limited():
	if underwater or eyes.is_colliding(): return false
	else: return true

func is_bonking():
	for bonker in tree.get_nodes_in_group('bonkers'):
		if bonker.is_colliding(): return true
	return false

func move_bonkers():
	var new = 0
	# 10(relic - 1) + 7
	if relicBoxes.size() == 0: new = -7
	else: new = (-12 * (relicBoxes.size() - 1) - 15)
	for bonker in tree.get_nodes_in_group('bonkers'):
		bonker.position.y = new

func wet_pc(signa : int):
	gravity += gravInc * signa
	vJump += jumpInc * signa
	sWalk += walkInc * signa

func switch_thrusters(switch):
	thrusters = switch

func detect_floors():
	for detector in tree.get_nodes_in_group('platDetectors'):
		if detector.is_colliding(): return true
	return false

#sound funcs
func throwav():
	possessor.set_stream(toss)
	possessor.play()

func jumpwav():
	if underwater: jamper.set_stream(borble)
	else: jamper.set_stream(jump)
	jamper.play()

func walkwav():
	if not walker.playing:
		walker.play()

func stop_walk():
#	yield(walker, "finished")
	walker.stop()
