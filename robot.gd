extends KinematicBody2D

export (PackedScene) var Box

var vertical_speed := 0.0
var jump_counter = 0
var thrusters = false
onready var plat_detect = $platDetector
onready var eyes = $Sight
onready var ani = $Ani

#solar charge vars
onready var display = $RoboPow
export var solarPower = 0
export var powerMax = 100
export var chargeTime = .2
export var chargeAmt = 1
export var depleteTime = .1
export var depleteAmt = 1.1
export var chargeMod = .5
export var jumpExhaust = 10
var powerChange = 0
var is_dead = false

#physics vars
export var vJump = 600
export var gravity = 200.0
export var sWalk = 200

#minimum physics variables
export var minWalk = 20
export var minGrav = 200
export var minJump = 30
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
onready var first_pos = Vector2(0, -8)
var pos_gap = Vector2(0, -12)
var relicBoxes = []
var underwater = false

signal grab(pos)
signal drop()
signal throw()

func _ready():
	thrusters = true
	$ChargeTimer.wait_time = chargeTime
	$DepleteTimer.wait_time = depleteTime
	solarPower = powerMax
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
	vJump -= vInc
	sWalk -= sInc
	if underwater:
		vJump -= vIncWet
		sWalk -= sIncWet

func remove_box():
	var nix = relicBoxes.pop_back()
	nix.queue_free()
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
	animate_bar()
#	TODO: fix checks so gravity still applies when battery dies
#	fix where battery depletes from gravity alone
	if solarPower == 0:
		battery_die()
	if solarPower > 0:
		if Input.is_action_pressed("right"):
			if sWalk < minWalk: velocity.x = minWalk
			else: velocity.x = sWalk
			facingDir = 'right'
			seeing(Vector2(sightDist-.5, 0))
			ani.play(facingDir)
		elif Input.is_action_pressed("left"):
			if sWalk < minWalk: velocity.x = -minWalk
			else: velocity.x = -sWalk
			facingDir = 'left'
			seeing(Vector2(-(sightDist+ 1) , 0))
			ani.play(facingDir)
		else: velocity.x = 0
	else: velocity.x = 0
	vertical_movement(delta)
	move_and_slide(velocity, Vector2(0, -1))
	if Input.is_action_just_pressed("pick_up"):
		emit_signal("grab", global_position)
	if Input.is_action_just_pressed("drop"):
		if Input.is_action_pressed("down"):
			emit_signal("drop")
		else: emit_signal("throw")

func disable_plat():
	plat_detect.enabled = false
	yield(get_tree().create_timer(.2, false), "timeout")
	plat_detect.enabled = true

func battery_die():
	set_physics_process(false)
#	is_dead = true
	yield(get_tree().create_timer(3, false), "timeout")
	solarPower = 20
#	is_dead = false
	set_physics_process(true)


func vertical_movement(delta):
	if gravity < minGrav : velocity.y += delta * minGrav
	else: velocity.y += delta * gravity
	if Input.is_action_just_pressed("jump") && thrusters && solarPower > 0:
		if jump_counter < 2 || not is_jump_limited():
			disable_plat()
			if vJump < minJump: velocity.y = -minJump
			else: velocity.y = -vJump
			if is_jump_limited():
				jump_counter +=1
			else: jump_counter = 0
	if plat_detect.is_colliding():
#		print('floo')
		jump_counter = 0
		velocity.y = 0
#		if gravity < minGrav : velocity.y -= delta * minGrav
#		else: velocity.y -= delta * gravity

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

func wet_pc(signa : int):
	gravity += gravInc * signa
	vJump += jumpInc * signa
	sWalk += walkInc * signa

func switch_thrusters(switch):
	thrusters = switch

func _on_DepleteTimer_timeout():
	if velocity != Vector2(): 
#		powerChange -= depleteRate
#		animate_bar(solarPower - depleteRate)
		solarPower -= depleteAmt

func _on_ChargeTimer_timeout():
#	powerChange += chargeRate
#	animate_bar(solarPower + chargeRate)
	solarPower += chargeAmt
	if underwater:
		solarPower -= chargeMod

func animate_bar():#final):
#	print(final)
	display.value = solarPower
#	print(powerChange)
#	$Tween.interpolate_property(display, 'value', solarPower, (solarPower + powerChange), .1)
#	$Tween.start()
#	solarPower += powerChange
#	powerChange = 0

#func move_bar():
#	var transform = get_tree().get_root().get_canvas_transform()
#	$RoboPow.value = solarPower
#	$RoboPow.rect_position = (transform.get_origin() * -1) # + Vector2(50, 0)
