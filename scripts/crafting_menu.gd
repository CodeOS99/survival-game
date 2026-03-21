extends Control

func _process(delta: float) -> void:
	curr_grid()

func curr_grid() -> Array[ItemData]:
	var grid: Array[ItemData] = []
	for child in $VBoxContainer/GridContainer.get_children():
		grid.append(null if not child.slot_data else child.slot_data.item)
	return grid
