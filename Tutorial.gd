extends Node2D

onready var zones = $zones.get_children()

func baby_steps():
	$gates/stepWall.set_deferred('disabled', true)

func bridge1_break():
	print('break')
	$gates/bridge.set_deferred('disabled', true)
	
func bridge2_break():
	print('break2')
	$gates/bridge2.set_deferred('disabled', true)

func disable_zone(nam):
	for zone in zones:
		if zone.name == nam:
			zone.set_deferred('disabled', true)

func enable_zone(nam):
	for zone in zones:
		if zone.name == nam:
			zone.set_deferred('disabled', false)
