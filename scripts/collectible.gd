extends Node3D

@export var outline_mesh: MeshInstance3D
@export var item: ItemData

func _ready() -> void:
	if outline_mesh == null:
		if $OutlineMesh:
			outline_mesh = $OutlineMesh # if an outline wasn't added but one of suitable name was found, use that
