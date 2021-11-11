extends KinematicBody2D

export (PackedScene) var Box

var vertical_speed := 0.0
var screen_size
var jump_counter = 0
onready var plat_detect = $platDetector
onready var ani = $Ani

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

onready var facingDir = $Head.get_animation()
onready var sightline = $Sight
onready var first_pos = Vector2(0, -8)
var pos_gap = Vector2(0, -12)
var relicBoxes = []
var underwater = false

signal grab(pos)
signal drop()
signal throw()

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

func remove_box():
	var nix = relicBoxes.pop_back()
	nix.queue_free()
	vJump += vInc
	sWalk += sInc

func get_in_front():
	var pos = global_position
	match(facingDir):
		'left':
			pos += Vector2(-10, 0)
			pass
		'right':
			pos += Vector2(10, 0)
	return pos

# Called when the node enters the scene tree for the first time.
func _ready():
#	var array = [1, 2, 3, 4, 5]
#	print(array.size())
	screen_size = get_viewport_rect().size

func seeing(pos):
	sightline.cast_to = pos
	sightline.force_raycast_update()

func _physics_process(delta):
	if Input.is_action_pressed("right"):
		if sWalk < minWalk: velocity.x = minWalk
		else: velocity.x = sWalk
		facingDir = 'right'
		seeing(Vector2(10, 0))
		ani.play(facingDir)
	elif Input.is_action_pressed("left"):
		if sWalk < minWalk: velocity.x = -minWalk
		else: velocity.x = -sWalk
		facingDir = 'left'
		seeing(Vector2(-10, 0))
		ani.play(facingDir)
	else:
		velocity.x = 0
#	if get_tree().current_scene.get_name().match("Main") :
#		if Input.is_action_pressed("ui_down"):
#			velocity.y = sWalk
#		elif Input.is_action_pressed("ui_up"):
#			velocity.y = -sWalk
#		else:
#			velocity.y = 0
	vertical_movement(delta)
#	get_tree().call_group('parts', 'move_and_slide', velocity, Vector2(0, -1))
#	global_position = $Full.global_position
	move_and_slide(velocity, Vector2(0, -1))
	if Input.is_action_just_pressed("pick_up"):
		emit_signal("grab", global_position)
	if Input.is_action_just_pressed("drop"):
		if Input.is_action_pressed("down"):
			emit_signal("drop")
		else: emit_signal("throw")

func start(pos):
	position = pos
	#target = pos
	show()
#	$CollisionShape2D.disabled = false

func vertical_movement(delta):
	velocity.y += delta * gravity
#	var local_Y = Vector2.UP
	if Input.is_action_just_pressed("jump"):
		if jump_counter < 2 || underwater:
			if vJump < minJump: velocity.y = -minJump
			else: velocity.y = -vJump
	#		velocity.y = -vJump
			if not underwater:
				jump_counter +=1
			else: jump_counter = 0
#	var k = move_and_slide(velocity, Vector2(0,-1)) 
	if plat_detect.is_colliding():
#		print('floo')
		jump_counter = 0
		if gravity < minGrav : velocity.y -= delta * minGrav
		else: velocity.y -= delta * gravity

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

func wet_pc(signa : int):
	gravity += gravInc * signa
	vJump += jumpInc * signa
	sWalk += walkInc * signa
