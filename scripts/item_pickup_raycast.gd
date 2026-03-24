extends RayCast3D

var prev_body: Node3D
var looking_at := false



func _physics_process(delta: float) -> void:
	if self.is_colliding():
		var body = self.get_collider()
		if body.is_in_group("Collectible"):
			$"../../../HUD/TextureRect".modulate = Color(1.0, 0.0, 0.0, 1.0)
			if prev_body:
				prev_body.outline_mesh.visible = false
			prev_body = body
			prev_body.outline_mesh.visible = true
			$"../../../HUD/Label".visible = true
			looking_at = true
		else:
			_not_looking()

	else:
		_not_looking()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pick_up") and looking_at:
		if Globals.player.inventory.add_item(prev_body.item):
			prev_body.queue_free()

func _not_looking():
	$"../../../HUD/TextureRect".modulate = Color(1.0, 1.0, 1.0, 1.0)
	if prev_body:
		prev_body.outline_mesh.visible = false
	$"../../../HUD/Label".visible = false
	looking_at = false
