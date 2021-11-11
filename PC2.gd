extends KinematicBody2D

var vertical_speed := 0.0
var screen_size
var jump_counter = 0
onready var plat_detect = $platDetector
onready var ani = $Ani
#jump physics vars
export var vJump = 600
export var gravity = 200.0
export var sWalk = 200
var velocity = Vector2()
onready var facingDir = $Head.get_animation()
onready var sightline = $Sight
onready var first_pos = Vector2(0, -8)
var pos_gap = Vector2(0, -12)

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
#poopoo
#func _unhandled_input(event):
#	pass

func _physics_process(delta):
	if Input.is_action_pressed("right"):
			velocity.x = sWalk
			facingDir = 'right'
			seeing(Vector2(10, 0))
			ani.play(facingDir)
	elif Input.is_action_pressed("left"):
			velocity.x = -sWalk
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
	if Input.is_action_just_pressed("jump") && jump_counter < 2 :
		velocity.y = -vJump
		jump_counter +=1
#	var k = move_and_slide(velocity, Vector2(0,-1)) 
	if plat_detect.is_colliding():
#		print('floo')
		jump_counter = 0
		velocity.y -= delta * gravity

func _add_to_inventory(icon):
	$PopupPanel/ItemList.add_icon_item(load(icon))
	pass
#
#func Hud_update():
#	dogCounter +=1
#	$HUD/Label.text = labeltext + String(dogCounter)

#func Hud_update2(Integer):
#	$HUD/Label.text = labeltext + String(Integer)

#func _on_PopupPanel_gui_input(event):
#	pass
