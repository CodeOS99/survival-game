extends StaticBody3D

@onready var mesh = $"tree-tall2"

var popout_log = preload("res://scenes/popout_log.tscn")

const MAX_HEALTH: float = 20.0
var health: int = MAX_HEALTH

func spawn_log():
	var log := popout_log.instantiate()
	get_tree().root.add_child(log)
	log.global_position = $LogPoint.global_position

func chopped(damage: float) -> bool: # also return whether its chopped or not
	for i in range(health-damage, health): # spawn a log every fourth damage
		if i % 4 == 0:
			self.spawn_log()

	health -= damage
	self.mesh.scale.x-=(damage/MAX_HEALTH*4.0)
	self.mesh.scale.y-=(damage/MAX_HEALTH*4.0)
	self.mesh.scale.z-=(damage/MAX_HEALTH*4.0)
	print(mesh.scale.x)
	Globals.player.shake_camera()
	
	return self.mesh.scale.x <= 0
