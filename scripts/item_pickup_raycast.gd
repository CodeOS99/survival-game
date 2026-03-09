extends RayCast3D

var prev_body: Node3D

func _physics_process(delta: float) -> void:
	if self.is_colliding():
		var body = self.get_collider()
		if body.is_in_group("Collectible"):
			$"../../../HUD/TextureRect".modulate = Color(1.0, 0.0, 0.0, 1.0)
			if prev_body:
				prev_body.outline_mesh.visible = false
			prev_body = body
			prev_body.outline_mesh.visible = true
		else:
			$"../../../HUD/TextureRect".modulate = Color(1.0, 1.0, 1.0, 1.0)
			if prev_body:
				prev_body.outline_mesh.visible = false
	else:
		$"../../../HUD/TextureRect".modulate = Color(1.0, 1.0, 1.0, 1.0)
		if prev_body:
			prev_body.outline_mesh.visible = false
