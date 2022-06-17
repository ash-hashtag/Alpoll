extends CSGCombiner3D

var enemy := preload("res://objects/enemy.tscn")
@onready var player := $Player

func _ready() -> void:
	for i in range(10):
		var enemyInstance := enemy.instantiate()
		add_child(enemyInstance)
	pass

func randomPos() -> Vector3:
	return Vector3(randf_range(-20, 20), 20 , randf_range(-20, 20))
