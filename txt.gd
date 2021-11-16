extends 'res://addons/SyndiBox/syndibox.gd'

onready var tree = get_tree()

var in_tutorial = true

signal first_steps
signal first_pick
signal second_fall

func _unhandled_input(event):
	if not in_tutorial: return
	if strings == opening_txts:
		if cur_set == strings.size() -1:
			if Input.is_action_pressed('left') || Input.is_action_pressed('right'):
				yield(get_tree().create_timer(1, false), "timeout")
				emit_signal("first_steps")
	if strings == first_relix_txts:
		if cur_set == strings.size() -1:
			if Input.is_action_pressed('pick_up'):
				emit_signal("first_pick")

func first_fall():
	strings = fall_txts
	tree.paused = true
	start()

func second_fall():
	strings = fallest_txts
	tree.paused = true
	start()

onready var opening_txts = PoolStringArray([
#	screen fades in
#	wait for a sec
	'..................', 
	'where did i leave that remote.....',
	'ok...... switch, ON',
	'...........',
	'ope... forgot to plug it in....',
	'*CLANG *CRASH *CLACK *CLACK *ZZZZZZZTTTTTT',
	'...........',
	'is it on?....',
	'hey, you out there, can you hear me?',
	'yes you, the sloppily concieved scrap pile with eyes',
	'they assured me you have "state-of-the-art" artificial intelligence and "advanced locomotive capabilities".... ',
	'look, i just push buttons on the remote... i hope you can handle the rest.....',
	'"WE" were stationed at this ancient ruin for one reason: to recover relix stolen from lost civilizations',
	'these ruins were used as a storehouse for an organization of thieves that operated in the distant past',
	'the thieves were on the payroll of an eccentric quintillionaire who believed all ancient cultures across the globe shared a secret technology that they hid away from their progeny...',
	"he called it the.... foolosopher's stone... ",
	'nice name....',
	'anyway the short of it is the world is drowning FAST, and a certain organization -"OUR" organization - is throwing a hail mary and having "US" investigate the truth behind the foolosopher' + "'s stone", 
	'"WE" have about a week before this whole place is underwater, and before that happens YOU need to recover as many relics as possible',
	'"I" will be your support, but i also have to analyze all the recovered relics so i won' + "'t have time to babysit you",
	"SO, let's get you up to speed with a little practice run.",
	"I'm handing over control of your basic motor functions now, give it a try...",
#	emit signal for movement tutorial
#	use walking_txts
])

var fallest_txts = PoolStringArray([
#	if user goes left
#	"ACCORDING TO THE MAP YOU HAVE TO GO RIGHT",
#	user falls again lmao
	"...........",
	"okay that MAY have been my fault",
	"you aren't getting out of there without ALL of your 'advanced locomotive capabilities'...",
	"I'm handing over control of your thrusters now, so try jumping...",
#	display user jump input map
#	wait for .5 sec after user jumps
	"Neat. You should be able to do several of those in a row, though you can probably manage more underwater.",
	"One last thing and i'll leave you to it, I'm giving you access to some critical info that's needed for your work.",
#	display charge meter / minimap (lol)
	"that bar in the upper right represents the amount of charge left in your battery.",
	"moving around depletes the bar, and if it's empty you will be stuck until a certain amount of charge is restored.",
	"not to worry though, solar tech has come a long way and you can recharge pretty quickly by staying still for a moment.",
#	BIG IF we get to the minimap explain that here
#	minimap text minimap text minimap text minimap text minimap text 
	"okay, that should be everything you need to know for this job. make your way back to the trailer ASAP",
	".......",
	"and don't forget the relic...."
	])

var fall_txts = PoolStringArray([
	#	wait for user to cross breakpoint
#	wait for user to finish falling
	"ope....",
	"........",
	"you okay down there?",
	"well nothing seems broken..... yet. so just try and get back to the trailer from there....",
	"according to the map you're gonna have to go to the right again...",
])

func pickup():
	tree.paused = true
	strings = first_relix_txts
	start()

func picked_up():
	yield(get_tree().create_timer(1, false), "timeout")
	tree.paused = true
	strings = pickup_txts
	start()

var first_relix_txts = PoolStringArray([
#	triggered when user enters specific area
	"okay, good job. See that weird looking square on the ground? That's a relix.",
	"............",
	"trust me, it may not look like much but I have an eye for this stuff...",
	"I'm handing over control of your local gravity manipulato- er.... ears now, so try picking it up",
])

var pickup_txts = PoolStringArray([
#	display user pick-up input map
#	wait for user to pick-up relic
	"nice. you seem quick on the uptake. remember that you can hold multiple relix at once, but they tend to be heavy so each one slows you down",
	"for now this one is enough so come back to the trailer, got it?",
])

var walking_txts = PoolStringArray([
#	display user left/right input maps
#	wait for .5 sec after user inputs left/right
	"alright good, you seem to be plenty motile.",
	"According to 'your' radar there is a relic due East of here, so go ahead and navigate to it...",
	".......",
	"East is... to the right....",
#   end and wait for first relix txts
	])

var defeat_txts = [
	"make ONE submission to a middle school robotics competition and they put you in charge of some rust bucket a week before doomsday"
	
	]

var retire_txts = [
	"quitting for the day? you know we're on a strict timer right?",
	"you're one heckuva lazy robot, you know that?",
	"done already? alright, take it easy fella...",
	"feeling okay? I can check your sprocket drivers for updates if you want?",
	"I know it's tough out there, but if we're gonna finish this job I need you to hustle...",
	]

func _ready():
	strings = opening_txts
	start()
	tree.paused = true

#cur_section is the index of the current string in the strings array
func _on_SyndiBox_section_finished(cur_section):
#	if cur_section == 8:
#		print('hey, you out there, can you hear me?')
	
	pass # Replace with function body.

func _on_SyndiBox_text_finished():
	match(strings):
		opening_txts:
			tree.paused = false
			yield(self, "first_steps")
			tree.paused = true
			strings = walking_txts
			start()
		walking_txts:
			tree.paused = false
		first_relix_txts:
			tree.paused = false
		pickup_txts:
			tree.paused = false
		fall_txts:
			tree.paused = false
			emit_signal("second_fall")
		fallest_txts:
			tree.paused = false
