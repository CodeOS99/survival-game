extends Control

@export var recipes: AllCraftingRecipes

var SIDE_LENGTH = 3

func _process(delta: float) -> void:
	var grid := curr_grid()
	
	for recipe in recipes.recipes:
		var used_slots = []
		for i in range(len(grid)):
			if grid[i] == recipe.items[0]: # found first item
				used_slots.append(i)
				var valid = true
				for j in range(1, len(recipe.pos)): # check if the other items are in place
					var pos = recipe.pos[j]
					var new_i = pos.x + pos.y * SIDE_LENGTH + i
					if new_i < len(grid): # in range
						if not grid[new_i] == recipe.items[j]: # not matching
							valid = false
							break
						else: # matching
							used_slots.append(new_i)
					else: # not in range
						valid = false
						break
				if not valid:
					continue
				print("valid recipe!")

func curr_grid() -> Array[ItemData]:
	var grid: Array[ItemData] = []
	for child in $VBoxContainer/GridContainer.get_children():
		grid.append(null if not child.slot_data else child.slot_data.item)
	return grid
