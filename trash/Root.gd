extends Node

enum COLLISION {credits,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,q,end}

onready var collayer = ['credits','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','q','end']

onready var levels = get_tree().get_nodes_in_group('levels')
onready var menu = get_node("Settings")

onready var billiard = $Billiard
onready var goalPlayer = $GoalPlayer
onready var fallPlayer = $FallPlayer
onready var contact = $Contact
onready var timer = $DisplayTimer
onready var active_level = levels[COLLISION.a]
onready var cage = $cage
onready var soundvolume = menu.get_soundvol()

# record time variables
onready var contactSpeed = 0
onready var pbMin = 0
onready var pbSec = 0

func _ready():
	load_level()
	load_times()
	menu.load2()
	contact.link = billiard
	contact.change_speed(menu.speed.selected)
	billiard.global_position = active_level.checkpoint.global_position
	contact.connect('slap', billiard, 'apply_central_impulse')
	active_level.arrive()
	for level in levels:
		level.connect('fall', self, 'move_down')
		level.connect('goal', self, 'move_up')

func move_down(level, pos):
#	animate transition
	var current = get_level(collayer[level]) 
	var next = get_level(collayer[level-1])
	current.go_away(false)
	next.arrive()
	active_level = next
	if soundvolume > 0:
		fallPlayer.play()
	contact.fallStreak += 1
	print('next '+ next.name)
	print(pos)

func move_up(level, pos):
#	animate transition
	var current = get_level(collayer[level]) 
	var next = get_level(collayer[level+1])
	current.go_away(true)
	next.arrive()
	if next.name == 'end':
		timer.stop()
		compare_times()
	active_level = next
	if soundvolume > 0:
		goalPlayer.play()
	contact.fallStreak = 0
#	print(soundPlayer.get_volume_db())	
	print('next '+ next.name)
	print(pos)
 
func get_level(lvlName):
	for level in levels:
		if level.name == lvlName:
			return level

func compare_times():
	if timer.mins < pbMin:
		print('pb')
		save_times()
	elif timer.mins == pbMin && timer.secs < pbSec:
		save_times()
		print('pb')
	elif pbMin == 0 && pbSec == 0:
		print('pb')
		save_times()

func _unhandled_input(event):
	if event.is_action_pressed("ui_focus_next"):
		checkpoint()
#		cheat()

func checkpoint():
	print('point')
	var pos = active_level.checkpoint.global_position
	cage.global_position = billiard.global_position
	yield(get_tree().create_timer(0.25), "timeout")
	billiard.global_position = pos
	cage.global_position = Vector2()

func cheat():
	get_tree().reload_current_scene()

func _on_Settings_menu(on):
	if on:
		billiard.set_visible(true)
		contact.set_visible(true)
		menu.menu_switch(false, Vector2())
	else:
		billiard.set_visible(false)
		contact.set_visible(false)
		menu.menu_switch(true, billiard.global_position)

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_level():
#	print('save level')
	var save_game = File.new()
	save_game.open("user://savelevel.save", File.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(to_json({
		'active_level': active_level.name,
#		'millis': timer.millis,
		'secs': timer.secs,
		'mins': timer.mins
		}))
	save_game.close()

func save_times():
	pbMin = timer.mins
	pbSec = timer.secs
	var save_game = File.new()
	save_game.open("user://savetimes.save", File.WRITE)
	save_game.store_line(to_json({
		'pbMin' : timer.mins,
		'pbSec' : timer.secs,
	}))
	save_game.close()

func load_times():
	var save_game = File.new()
	if not save_game.file_exists("user://savetimes.save"):
		pbMin = 0
		pbSec = 0
		return # Error! We don't have a save to load.
	print('file')
	save_game.open("user://savetimes.save", File.READ)
	var node_data = parse_json(save_game.get_line())
	
	pbMin = node_data['pbMin']
	pbSec = node_data['pbSec']
	
	save_game.close()
	timer.set_pb(pbMin, pbSec)

# %APPDATA%\Godot\ file path for save data on windows
func load_level():
	var save_game = File.new()
	if not save_game.file_exists("user://savelevel.save"):
		return # Error! We don't have a save to load.

	save_game.open("user://savelevel.save", File.READ)
	var node_data = parse_json(save_game.get_line())
	active_level = get_level(node_data["active_level"])
#	timer.millis = node_data['millis']
	timer.secs = node_data['secs']
	timer.mins = node_data['mins']
	save_game.close()

func _on_Settings_sound_changed(vol):
	if soundvolume > 0:
		if vol == 0:
			contact.sounds = false
	if soundvolume == 0:
		if vol > 0:
			contact.sounds = true
	soundvolume = vol

func _on_Settings_invert_controls(switch):
		contact.inverted = switch

func _on_Settings_save_quit():
	save_level()
	get_tree().quit()

func _on_Settings_speed_change(index):
	contact.change_speed(index)
