extends StaticBody3D

@onready var mesh = $"mesh"

var popout_minerals = [preload("res://scenes/popout_raw_iron.tscn"), preload("res://scenes/popout_coal.tscn")]

const MAX_HEALTH: float = 20.0
var health: int = MAX_HEALTH

func spawn_mineral():
	var mineral = popout_minerals.pick_random().instantiate()
	get_tree().root.add_child(mineral)
	mineral.global_position = $MineralPoint.global_position

func chopped(damage: float) -> bool: # also return whether its chopped or not
	for i in range(health-damage, health): # spawn a log every fourth damage
		if i % 4 == 0:
			self.spawn_mineral()
			$Pop.play()

	health -= damage
	self.scale.x-=(damage/MAX_HEALTH*1)
	self.scale.y-=(damage/MAX_HEALTH*1)
	self.scale.z-=(damage/MAX_HEALTH*1)

	Globals.player.shake_camera()
	
	return self.scale.x <= 0
