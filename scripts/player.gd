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
@onready var gunCam := $Camera3D/SubViewportContainer/SubViewport/Camera3D
var bulletCount:= 30
var totalBullets := 270
var hasGun := true
var respawn := false
@onready var initialTrans := global_transform

func _ready():
	camera_joint = $Camera3D
	fps_label = $Camera3D/Control/Label
	ground_ray_cast = $RayCast3D
	mouseSensi = $Camera3D/escaped/HSlider.value
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D/escaped/resume.button_down.connect(escapeOut)
	$Camera3D/escaped/quit.button_down.connect(quit)

func quit() -> void:
	get_tree().quit()

func _process(delta):
	gunCam.global_transform = camera_joint.global_transform


func _physics_process(_delta):
	fps_label.text = str(Engine.get_frames_per_second())
	movement(_delta)
	if respawn:
		global_transform = initialTrans
		respawn = false

func _input(event):
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			mouseDelta = event.relative
	elif event.is_action_pressed("ui_cam"):
		if camera_joint.fov < 60:
			camera_joint.fov = 75
		else: camera_joint.fov = 15

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		escapeOut()

func _on_h_slider_value_changed(value):
	mouseSensi = value

func _on_button_button_down():
	escapeOut()
	respawn = true

func movement(_delta: float) -> void:
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
		
	if mouseDelta != Vector2.ZERO:
		var temp :float = mouseSensi * _delta
		camera_joint.rotation.x -= mouseDelta.y * temp
		camera_joint.rotation.x = clamp(camera_joint.rotation.x, maxLookDown, maxLookUp)
		rotation.y -= mouseDelta.x * temp
		mouseDelta = Vector2.ZERO

func escapeOut():
	if $Camera3D/escaped.visible:
		$Camera3D/escaped.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		$Camera3D/escaped.visible = true
