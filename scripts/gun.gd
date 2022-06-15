extends Node3D
@onready
var anim_player := $AnimationPlayer
@onready var timer := $Timer
var reloading := false
var shooting := false

func setState(player = null):
	if shooting:
		anim_player.play("firing")
	else:
		anim_player.play("RESET")
	if reloading:
		anim_player.play("reload")
		player.bullet_label.text = "reloading..."
		await anim_player.animation_finished
		reloading = false
		player.bulletCount = 30
		player.totalBullets -= 30
		player.bullet_label.text = "30 | " + str(player.totalBullets)
		setState()
	pass
