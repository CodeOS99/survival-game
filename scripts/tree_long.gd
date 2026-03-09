extends StaticBody3D

@onready var mesh = $"tree-tall2"

var popout_log = preload("res://scenes/popout_log.tscn")

func spawn_log():
	var log := popout_log.instantiate()
	get_tree().root.add_child(log)
	log.global_position = $LogPoint.global_position

func chopped():
	self.mesh.scale.x-=1
	self.mesh.scale.y-=1
	self.mesh.scale.z-=1
	self.spawn_log()
	
	return self.mesh.scale.x <= 0
