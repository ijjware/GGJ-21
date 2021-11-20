extends Node2D

onready var warble = preload('res://sounds/warble3.wav')
onready var sand = preload('res://sounds/sand2.wav')

onready var tieD = $tieD
onready var numLabel = $Recovered
onready var sound = $Sounds

var counter = 0
var recoveredString := ''

signal finished

func end_screen():
	$Counter.start()

func _on_Counter_timeout():
	if Global.relixRecovered == 0:
		build_recovery(0)
	if counter < Global.relixRecovered:
		if not sound.is_playing():
			warble()
			sound.play(0)
		counter += 1
		build_recovery(counter)
	else:
		sound.stop()
		counter = 0
		$Counter.stop()
		yield(get_tree().create_timer(1, false), "timeout")
		print_days()

func build_recovery(num):
	recoveredString = 'Relix Recovered : ' + num as String + '/' + Global.numRelix as String 
	numLabel.set_text(recoveredString)

func print_days():
	tieD.set_color(Color(.7,.3,.3))
#	tieD.buff_silence(.75)
	tieD.buff_text(Global.daysLeft as String)
	tieD.set_state(tieD.STATE_OUTPUT)
	sand()
	sound.play(0)

func warble():
	sound.set_stream(warble)

func sand():
	sound.set_stream(sand)

func _on_tieD_buff_end():
	emit_signal("finished")
	tieD.buff_clear()
	
