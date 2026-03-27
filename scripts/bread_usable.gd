extends Node3D

var needs_hotbar_ref = true
var hotbar_ref: HotbarSlot
var using = false

var hunger_cost = -5 # not sure if this is a good way to do this
# certainly the one which uses the smallest amount of lines :P

func use() -> void:
	self.queue_free()
	hotbar_ref.slot_data.amount -= 1
	if hotbar_ref.slot_data.amount <= 0:
		hotbar_ref.slot_data = null
		hotbar_ref.update_visuals()
