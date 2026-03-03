extends Node3D

func use():
	$AnimationPlayer.play("lmb")

func reset():
	$AnimationPlayer.play("RESET")
