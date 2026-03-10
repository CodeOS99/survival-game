extends Node

@export var to_bob: Node3D # would by default be set to the parent in the ready function

@export var BOB_FREQ := 2.4
@export var BOB_AMP := 0.08
var t_bob = 0.0

var base_position: Vector3

func _ready() -> void:
	if to_bob == null:
		to_bob = get_parent()
	
	base_position = to_bob.transform.origin

func _process(delta: float) -> void:
	if "should_bob" in to_bob:
		if not to_bob.should_bob:
			return
	t_bob += delta * Globals.player.velocity.length() * float(Globals.player.is_on_floor())
	to_bob.transform.origin = base_position + _headbob(t_bob)

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
