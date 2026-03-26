extends RigidBody3D

const HORIZONTAL_FORCE: float = 4.0
const VERTICAL_FORCE: float = 4.0

@onready var outline_mesh: MeshInstance3D = $OutlineMesh

var base_position: Vector3
var time := 0.0
var landed := false

var item: ItemData = preload("res://resources/inventory/raw_iron.tres")

func _ready() -> void:
	var dir = Vector3(randf_range(-0.5,0.5), 0, randf_range(-0.5,0.5)).normalized()
	apply_impulse(dir * HORIZONTAL_FORCE + Vector3.UP * VERTICAL_FORCE)
