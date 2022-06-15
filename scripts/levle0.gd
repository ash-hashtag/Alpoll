extends CSGCombiner3D

var enemy := preload("res://objects/enemy.tscn")

func _ready() -> void:
	for i in range(10):
		var enemyInstance := enemy.instantiate()
		enemyInstance.global_transform.origin = randomPos()
		call_deferred("add_child", enemyInstance)

func randomPos() -> Vector3:
	return Vector3(randf_range(-20, 20), 40 , randf_range(-20, 20))
