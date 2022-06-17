extends Node3D

const mag_size: int = 500
@export var total_bullets: int = 3000
var bullets := mag_size
@onready var anim_player := $AnimationPlayer
var reloading := false
var shooting := false

func _ready():
	$Timer.timeout.connect(get_parent().timeout)

func _input(event):
	if event.is_action_pressed("ui_fire"):
		if !reloading: 
			shooting = true
			anim_player.play("firing")
	elif event.is_action_released("ui_fire"):
		shooting = false
		if !reloading: 
			anim_player.stop()
		anim_player.queue("RESET")
	elif event.is_action_pressed("reload"):
		reload()

func reload():
	reloading = true
	shooting = false
	anim_player.play("reload")
	await anim_player.animation_finished
	reloading = false
	bullets = mag_size
	total_bullets -= mag_size
