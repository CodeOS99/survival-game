extends Node3D

@export var damage_per_swing = 1
@export var max_durability = 8
@export var particle_point: Node3D
@export var max_per_swing: int = 1
@export var break_particles: PackedScene

@onready var area: Area3D = $Area3D

var break_sfx := preload("res://assets/sound/sfx/break_sfx.mp3")

var using: bool = false
var hit_trees = [] # if performance becomes an issue i could give every tree and index, and then binary search along this array to find if the tree exists although i don't think it will be an issue

var tree_particle = preload("res://scenes/tree_blast_particles.tscn")

var curr_durability = max_durability

func _ready() -> void:
	$Control/ProgressBar.max_value = max_durability
	$Control/ProgressBar.value = curr_durability

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
			if body.is_in_group("Tree") and body not in hit_trees and len(hit_trees)+1 <= max_per_swing:
				if body.chopped(damage_per_swing):
					body.queue_free()
				hit_trees.append(body)
				$Control/ProgressBar.value = curr_durability

				spawn_tree_particle()
				
				curr_durability -= damage_per_swing
				
				if curr_durability <= 0:
					var particles = break_particles.instantiate()
					get_tree().root.add_child(particles)
					particles.global_position = particle_point.global_position
					particles.emitting = true
					
					var player := AudioStreamPlayer.new()
					player.stream = break_sfx
					get_tree().root.add_child(player)
					player.play()
					
					self.queue_free() # broke

func spawn_tree_particle():
	var particles = tree_particle.instantiate()
	get_tree().root.add_child(particles)
	particles.global_position = particle_point.global_position
	particles.emitting = true
