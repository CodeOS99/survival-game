extends Node3D

var using: bool = false

func use():
	$AnimationPlayer.play("lmb")
	using = true

func reset():
	pass # nothing needs to happen if the player stop pressing lmb

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "lmb":
		using = false
