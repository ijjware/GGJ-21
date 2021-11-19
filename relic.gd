extends RigidBody2D

onready var ani = $AnimationPlayer
onready var tree = get_tree() #.get_nodes_in_group('relics')
onready var index

var link
var is_held = false

func _ready():
	hold_switch(is_held)

func animate(string):
	ani.play(string)

func hold_switch(held):
	is_held = held
	if held:
		mode = MODE_STATIC
	else:
		mode = MODE_CHARACTER

func slap(power):
	tree.call_group('relics', 'set_collision_mask_bit', 2, false)
	linear_velocity = Vector2()
	apply_central_impulse(power)
	yield(get_tree().create_timer(.2, false), "timeout")
	tree.call_group('relics', 'set_collision_mask_bit', 2, true)

func _physics_process(delta):
	if is_held:
		linear_velocity = Vector2()
		global_position = link.head_pos(index)
