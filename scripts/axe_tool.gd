extends Node3D

@onready var area: Area3D = $Area3D

var using: bool = false
var hit_trees = [] # if performance becomes an issue i could give every tree and index, and then binary search along this array to find if the tree exists although i don't think it will be an issue

func use():
	$AnimationPlayer.play("lmb")
	using = true

func reset():
	pass # nothing needs to happen if the player stop pressing lmb

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "lmb":
		using = false
		hit_trees = []

func _process(delta: float) -> void:
	if using:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("Tree") and body not in hit_trees:
				if body.chopped():
					body.queue_free()
				hit_trees.append(body)
			
