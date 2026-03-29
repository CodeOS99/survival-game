extends CharacterBody3D

const SPEED = 4.0
const ATTACK_RANGE = 2.4
var health = 3
var is_dead = false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $mesh/AnimationPlayer

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		move_and_slide()
		return
	if is_dead:
		return
	
	look_at(Globals.player.global_position)
	rotation.y += PI
	var is_attacking = anim_player.current_animation == "SkeletonMinion/Throw"
	var is_hit = anim_player.current_animation == "SkeletonMinion/Hit_A"
	if _target_in_range() or is_attacking or is_hit:
		velocity = Vector3.ZERO
		if not is_attacking and not is_hit:
			anim_player.play("SkeletonMinion/Throw")
	else:
		nav_agent.set_target_position(Globals.player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		if anim_player.current_animation != "SkeletonMinion/Running_A":
			anim_player.play("SkeletonMinion/Running_A")
	
	move_and_slide()

func take_damage(amt: int) -> void:
	if is_dead:
		return
	health -= amt
	print(health)
	if health <= 0:
		print("hee")
		_die()
	else:
		anim_player.stop()
		anim_player.play("SkeletonMinion/Hit_A")

func _die() -> void:
	is_dead = true
	velocity = Vector3.ZERO
	anim_player.stop()
	anim_player.play("SkeletonMinion/Death_A")
	await anim_player.animation_finished
	anim_player.play("SkeletonMinion/Death_A_Pose")

	var meshes = []
	for child in find_children("*", "MeshInstance3D", true, false):
		var mat = child.mesh.surface_get_material(0).duplicate()
		mat.flags_transparent = true
		child.set_surface_override_material(0, mat)
		meshes.append(child)

	var tween = create_tween()
	for m in meshes:
		tween.parallel().tween_method(
			func(a): m.get_surface_override_material(0).albedo_color.a = a,
			1.0, 0.0, 1.5
		)
	await tween.finished
	queue_free()

func _target_in_range() -> bool:
	return global_position.distance_to(Globals.player.global_position) <= ATTACK_RANGE
