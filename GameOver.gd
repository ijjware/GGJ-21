extends Node


func _ready():
#	'Your Time : ' + Global.totalSecs as String + ' Seconds'
	$lblRelix.set_text('Relix Recovered : ' + Global.relixRecovered as String + '/' + Global.numRelix as String)
	$lblTime.set_text('Your Time : ' + Global.totalSecs as String + ' Seconds')
	$AnimationPlayer.play("fades")
