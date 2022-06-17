extends Node3D

var hasGun := true
@onready var gun := get_child(1)
@onready var ray: RayCast3D = get_parent().get_node("RayCast3D")
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var bullet_label: Label = get_parent().get_node("Control/Label2")


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if hasGun:
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					hasGun = false
					gun.anim_player.play("noGun")
					await gun.anim_player.animation_finished
					remove_child(gun)
			else:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					add_child(gun)
					hasGun = true
					gun.anim_player.play_backwards("noGun")
	pass

func timeout() -> void:
	if gun.shooting && !gun.reloading:
		if gun.bullets > 0:
			if ray.is_colliding():
				particles.global_transform.origin = ray.get_collision_point()
				particles.look_at(global_transform.origin)
				if !particles.emitting: particles.emitting = true
				var collider := ray.get_collider()
				if collider.is_in_group("enemy"):
					collider.take_damage()
				if collider is RigidDynamicBody3D: 
					collider.apply_impulse((particles.global_transform.origin - global_transform.origin).normalized() * 4)
			elif particles.emitting: particles.emitting = false
			gun.bullets -= 1
			bullet_label.text = str(gun.bullets) + " | " + str(gun.total_bullets)
		else:
			gun.reload()
	elif particles.emitting: particles.emitting = false
	pass
