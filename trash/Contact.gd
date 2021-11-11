extends Position2D

onready var cue = $Cue
onready var contact = self
onready var charge = $Cue/Charge
onready var link = self

var short_pop = preload("res://sounds/zapsplat_cartoon_pop_high_pitched_sharp_001_73438.mp3")
var short_fart = preload("res://sounds/326143__mackaffee__fart.mp3")
var long_pop = preload("res://sounds/zapsplat_cartoon_pop_bubble_005_73432.mp3")
var long_fart = preload("res://sounds/177050__smokenweewalt__fart.wav")
var bar_charge = preload('res://art/bar_charge.png')
var meme_charge = preload('res://art/meme_charge.png')

var clock = false
var unclock = false
var moving = false
var powerCharge = false
var chargeRate = 15
var powerLim = 1000
var rotationRate = 4
var power = 0
var slope = Vector2()
var slap = Vector2()
var fallStreak = 0
var sounds = true
var inverted = false

signal slap(force)

func _ready():
	charge.max_value = powerLim

func _unhandled_input(event):
	if event.is_action_pressed("ui_left"):
#		print('left')
		unclock = true
		clock = false
	if event.is_action_pressed("ui_right"):
		clock = true
		unclock = false
	if event.is_action_released("ui_left"):
		unclock = false
	if event.is_action_released("ui_right"):
		clock = false
	if event.is_action_pressed("ui_charge"):
		powerCharge = true
		pass
	if event.is_action_released("ui_charge"):
		powerCharge = false
		get_force()

func _physics_process(delta):
	if fallStreak > 2 : charge.set_progress_texture(meme_charge)
	else: charge.set_progress_texture(bar_charge)
	global_position = link.global_position
	if clock == true && not moving:
		if not inverted: contact.rotation_degrees += rotationRate
		if inverted: contact.rotation_degrees -= rotationRate
	if unclock == true && not moving:
		if not inverted: contact.rotation_degrees -= rotationRate
		if inverted: contact.rotation_degrees += rotationRate
	if powerCharge == true && power < powerLim:
		power += chargeRate
#		print(power)
	charge.value = power
	calculate_slope()

func calculate_slope():
	var a = cue.global_position
	var b = contact.global_position
	slope = a.direction_to(b)

func get_force():
	slap.x = slope.x * power
	slap.y = slope.y * power
	emit_signal('slap', slap)
	if power < powerLim/2: short_sound()
	else: long_sound()
#	print(power)
	power = 0

func short_sound():
	
	if fallStreak < 3: $AudioStreamPlayer2D.set_stream(short_pop)
	else: $AudioStreamPlayer2D.set_stream(short_fart)
	if sounds:
		$AudioStreamPlayer2D.play()

func long_sound():
	if fallStreak < 3:
		$AudioStreamPlayer2D.set_stream(long_pop)
		if sounds: $AudioStreamPlayer2D.play()
	else:
		$AudioStreamPlayer2D.set_stream(long_fart)
		if sounds: $AudioStreamPlayer2D.play(0.6)

func change_speed(index):
	match(index):
		0:
			rotationRate = 3
			chargeRate = 20
		1:
			rotationRate = 2
			chargeRate = 10
		2:
			rotationRate = 4
			chargeRate = 30
