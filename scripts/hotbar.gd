class_name Hotbar extends Control

var active_slot_idx := 0

func _process(delta: float) -> void:
	var active_slot: Panel = $HBoxContainer.get_child(active_slot_idx)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.596, 0.596, 0.596, 0.5)
	
	active_slot.add_theme_stylebox_override("panel", style)
	
	for i in range(1, 10):
		if Input.is_action_just_pressed("slot_%d" % i):
			set_active_slot(i-1)

func set_active_slot(index: int):
	var active_slot: Panel = $HBoxContainer.get_child(active_slot_idx)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	
	active_slot.add_theme_stylebox_override("panel", style)
	
	active_slot_idx = index

func get_active_item() -> ItemData:
	return null if not $HBoxContainer.get_child(active_slot_idx).slot_data else $HBoxContainer.get_child(active_slot_idx).slot_data.item
