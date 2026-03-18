extends RigidBody3D

const HORIZONTAL_FORCE: float = 50.0
const VERTICAL_FORCE: float = 50.0

@onready var outline_mesh: MeshInstance3D = $OutlineMesh

var base_position: Vector3
var time := 0.0
var landed := false

var item: ItemData = preload("res://resources/inventory/log.tres")

func _ready() -> void:
	var dir = Vector3(randf_range(-0.5,0.5), 0, randf_range(-0.5,0.5)).normalized()
	apply_impulse(dir * HORIZONTAL_FORCE + Vector3.UP * VERTICAL_FORCE)

#
#func _physics_process(delta: float) -> void:
	#if not landed and get_contact_count() > 0:
		#start_idle()
#
#func start_idle():
	#landed = true
	#freeze = true
	#base_position = global_position
	#set_process(true)
#
#func _process(delta: float) -> void:
	#if landed:
		#time += delta
		#global_position.y = base_position.y + sin(time * 2.0) * 0.1
