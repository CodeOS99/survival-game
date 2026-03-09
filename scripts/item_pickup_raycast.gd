extends RayCast3D

func _physics_process(delta: float) -> void:
	if self.is_colliding():
		var body = self.get_collider()
		print("Boo hoo")
		if body.is_in_group("Collectible"):
			$"../../../HUD/TextureRect".modulate = Color(1.0, 0.0, 0.0, 1.0)
			print("heeheeheehaw")
		else:
			$"../../../HUD/TextureRect".modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		$"../../../HUD/TextureRect".modulate = Color(1.0, 1.0, 1.0, 1.0)
