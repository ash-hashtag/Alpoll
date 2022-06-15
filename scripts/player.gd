extends RigidDynamicBody3D

const moveVel:= 1000
const maxLookUp:= 1.5
const maxLookDown:= -1.5

var shoot_ray_cast :RayCast3D

var mouseSensi: float

var camera_joint: Camera3D
var fps_label: Label
var ground_ray_cast : RayCast3D
var mouseDelta := Vector2.ZERO
@onready var particles: GPUParticles3D = $GunPos/GPUParticles3D
@onready var bullet_label: Label = $Control/Label2
@onready var gun := $GunPos
@onready var gun_handle = $Camera3D/gun_handle
@onready var gunCam := $Camera3D/SubViewportContainer/SubViewport/Camera3D
var bulletCount:= 30
var totalBullets := 270
var hasGun := true
var respawn := false
var isPaused := false
@onready var initialTrans := global_transform

func _ready():
	camera_joint = $Camera3D
	fps_label = $Control/Label
	ground_ray_cast = $RayCast3D
	mouseSensi = $Control/HSlider.value
	shoot_ray_cast = $Camera3D/RayCast3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	gunCam.global_transform = camera_joint.global_transform


func _physics_process(_delta):
	if mouseDelta != Vector2.ZERO:
		var temp :float = mouseSensi * _delta
		camera_joint.rotation.x -= mouseDelta.y * temp
		camera_joint.rotation.x = clamp(camera_joint.rotation.x, maxLookDown, maxLookUp)
		rotation.y -= mouseDelta.x * temp
		mouseDelta = Vector2.ZERO
	
	fps_label.text = str(Engine.get_frames_per_second())
	
	var dir := Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		dir += global_transform.basis.z
	if Input.is_action_pressed("ui_down"):
		dir -= global_transform.basis.z
	if Input.is_action_pressed("ui_left"):
		dir += global_transform.basis.x
	if Input.is_action_pressed("ui_right"):
		dir -= global_transform.basis.x
	if dir != Vector3.ZERO:
		dir = dir.normalized() *moveVel *_delta
		linear_velocity.x = dir.x
		linear_velocity.z = dir.z
	else:
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, 5 * _delta)
		
	if Input.is_action_just_pressed("ui_jump") && ground_ray_cast.is_colliding():
		linear_velocity.y = 32
		
	if hasGun:
		gun.global_transform = gun_handle.global_transform
		if gun.shooting && !gun.reloading:
			if bulletCount > 0:
				if shoot_ray_cast.is_colliding():
					particles.global_transform.origin = shoot_ray_cast.get_collision_point()
					particles.look_at(global_transform.origin)
					if !particles.emitting: particles.emitting = true
					if gun.timer.is_stopped():
						gun.timer.start()
						var collider := shoot_ray_cast.get_collider()
						if collider.is_in_group("enemy"):
							collider.take_damage()
						if collider is RigidDynamicBody3D: 
							collider.apply_impulse((particles.global_transform.origin - global_transform.origin).normalized()*0.4)
						bulletCount -= 1
						bullet_label.text = str(bulletCount) + " | " + str(totalBullets)
				elif particles.emitting: particles.emitting = false
			else:
				reload()
		elif particles.emitting: particles.emitting = false
	if respawn:
		global_transform = initialTrans
		respawn = false

func _input(event):
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			mouseDelta = event.relative
		elif event is InputEventMouseButton:
			if event.is_pressed() && (event.button_index == MOUSE_BUTTON_WHEEL_DOWN || event.button_index == MOUSE_BUTTON_WHEEL_UP):
				if hasGun:
					hasGun = false
					gun.anim_player.play("reload")
					await gun.anim_player.animation_finished
					remove_child(gun)
				else:
					add_child(gun)
					gun.anim_player.play("reload")
					await gun.anim_player.animation_finished
					hasGun = true
			elif event.is_action("ui_fire"):
				gun.shooting = !gun.shooting
				if !gun.reloading: gun.setState()
	elif event.is_action_pressed("ui_cancel"):
		escapeOut()
	elif event.is_action_pressed("reload"):
		reload()

func reload(): 
	gun.reloading = true
	gun.setState(self)

func _on_h_slider_value_changed(value):
	mouseSensi = value

func _on_button_button_down():
	escapeOut()
	respawn = true

func escapeOut():
	if $Control/HSlider.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Control/TextureRect.visible = true
		isPaused = false
		$Control/HSlider.visible = false
		$Control/Button.visible = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Control/TextureRect.visible = false
		isPaused = true
		$Control/HSlider.visible = true
		$Control/Button.visible = true
