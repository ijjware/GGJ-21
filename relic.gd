extends RigidBody2D

onready var ani = $AnimationPlayer
onready var index

var link
var is_held = false

func animate(string):
	ani.play(string)

func hold_switch(held):
	is_held = held
	if held:
		mode = MODE_STATIC
	else:
		mode = MODE_CHARACTER

func slap(power):
	print(linear_velocity)
	print(applied_force)
	$CollisionShape2D.set_deferred('disabled', true)
	linear_velocity = Vector2()
	print(power)
	apply_central_impulse(power)
	yield(get_tree().create_timer(.1, false), "timeout")
	$CollisionShape2D.set_deferred('disabled', false)

func _physics_process(delta):
	if is_held:
		global_position = link.head_pos(index)
		linear_velocity = Vector2()