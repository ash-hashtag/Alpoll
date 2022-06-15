extends RigidDynamicBody3D

const damage := 5
var health := 100
@onready var health_label := $Label3D
@onready var anim_player := $AnimationPlayer

func _ready() -> void:
	pass

func take_damage() -> void:
	health -= 5
	health_label.text = str(health)
	if !anim_player.is_playing():
		anim_player.play("health_loss")
	if health == 0:
		global_transform.origin = get_parent().randomPos()
		health = 100

func _on_timer_timeout() -> void:
	if global_transform.origin.y < -10:
		global_transform.origin = get_parent().randomPos()
