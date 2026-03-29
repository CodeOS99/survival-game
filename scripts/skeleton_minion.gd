extends CharacterBody3D

const SPEED = 4.0
const ATTACK_RANGE = 2.4

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $mesh/AnimationPlayer

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		move_and_slide()
		return
	
	look_at(Globals.player.global_position)
	rotation.y += PI

	var is_attacking = anim_player.current_animation == "SkeletonMinion/Throw"

	if _target_in_range() or is_attacking:
		velocity = Vector3.ZERO
		if not is_attacking:
			anim_player.play("SkeletonMinion/Throw")
	else:
		# Chase player
		nav_agent.set_target_position(Globals.player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		if anim_player.current_animation != "SkeletonMinion/Running_A":
			anim_player.play("SkeletonMinion/Running_A")
	
	move_and_slide()

func _target_in_range() -> bool:
	return global_position.distance_to(Globals.player.global_position) <= ATTACK_RANGE
