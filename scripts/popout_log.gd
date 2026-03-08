extends RigidBody3D

const horizontal_force: float = 50.0
const vertical_force: float = 50.0

func _ready() -> void:
	var dir = Vector3(randf_range(-0.5,0.5), 0, randf_range(-0.5,0.5)).normalized()
	self.apply_impulse(dir * horizontal_force + Vector3.UP * vertical_force)

func _process(delta: float) -> void:
	pass
