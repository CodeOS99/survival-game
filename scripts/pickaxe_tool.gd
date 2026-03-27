extends Node3D

@export var damage_per_swing = 1
@export var particle_point: Node3D
@export var max_per_swing: int = 1
@export var hunger_cost: float = 1.25

@onready var area: Area3D = $Area3D

var using: bool = false
var hit_ores = [] # if performance becomes an issue i could give every tree and index, and then binary search along this array to find if the tree exists although i don't think it will be an issue

var ore_particle = preload("res://scenes/ore_particles.tscn")

func use():
	$AnimationPlayer.play("lmb")
	$Swoosh.play()
	using = true

func reset():
	pass # nothing needs to happen if the player stop pressing lmb

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "lmb":
		using = false
		hit_ores = []

func _process(delta: float) -> void:
	if using:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("Ore") and body not in hit_ores and len(hit_ores)+1 <= max_per_swing:
				if body.chopped(damage_per_swing):
					body.queue_free()
				$PickaxeOnOre.play()
				hit_ores.append(body)

				spawn_tree_particle()
				
func spawn_tree_particle():
	var particles = ore_particle.instantiate()
	get_tree().root.add_child(particles)
	particles.global_position = particle_point.global_position
	particles.emitting = true
