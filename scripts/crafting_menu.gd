extends Control

@export var recipes: AllCraftingRecipes

@onready var craft_button = $HBoxContainer/CrafitngGrid/CraftButton
@onready var result_rect = $HBoxContainer/ResultContainer/PanelContainer/ResultTextureRect
@onready var result_amount_label = $HBoxContainer/ResultContainer/PanelContainer/ResultAmountLabel

var SIDE_LENGTH = 3

var curr_valid_recipe: CraftingRecipe
var curr_recipe_start: int = -1

func _process(delta: float) -> void:
	var grid := curr_grid()
	
	# reset the result container.
	craft_button.disabled = false
	result_rect.texture = null
	result_amount_label.text = ""
	
	# recipe related variables reset
	curr_valid_recipe = null
	curr_recipe_start = -1
	
	var prev_recipe_start = -1
	
	for recipe in recipes.recipes:
		var used_slots: Array[int]
		if curr_valid_recipe:
			break
		for i in range(len(grid)):
			if not grid[i]: # no way for this to match the recipe's first item since its null
				continue
			
			if grid[i].item == recipe.items[0]: # found first item
				used_slots = [i]
				prev_recipe_start = i
				if not grid[i].amount >= recipe.amounts[0]: # not enough first slot
					continue
				var valid = true
				for j in range(1, len(recipe.pos)): # check if the other items are in place
					# i -> the slot index in the crafing menu
					# j -> the index of the current item in the current recipe
					
					var pos = recipe.pos[j]
					
					var x_coord = i % SIDE_LENGTH # in the grid i mean
					var y_coord = i / SIDE_LENGTH
					
					if (x_coord + pos.x >= SIDE_LENGTH or x_coord + pos.x < 0) or (y_coord + pos.y >= SIDE_LENGTH or y_coord + pos.y < 0):
						valid = false
						break
					var new_i = x_coord + pos.x + (y_coord + pos.y) * SIDE_LENGTH
					
					if new_i < len(grid): # in range
						if not grid[new_i]: # no way for this to match the recipe's j^th item since its null
							valid = false
							break
						if not grid[new_i].item == recipe.items[j]: # not matching
							valid = false
							break
						else: # matching
							if not grid[new_i].amount >= recipe.amounts[j]: # not enoguh
								valid = false
								break
							used_slots.append(new_i)
					else: # not in range
						valid = false
						break
				if not valid:
					continue
			else:
				continue
			# the pattern is matched, but there may be extra items
			var nothing_extra = true
			for j in range(len(grid)):
				if j not in used_slots:
					if grid[j]:
						nothing_extra = false
						break
			
			if nothing_extra:
				craft_button.disabled = false
				result_rect.texture = recipe.result.texture
				result_amount_label.text = "x" + str(recipe.result_amount)
				
				curr_valid_recipe = recipe
				curr_recipe_start = prev_recipe_start
				
				break
			else:
				continue

func curr_grid() -> Array[SlotData]:
	var grid: Array[SlotData] = []
	for child in $HBoxContainer/CrafitngGrid/GridContainer.get_children():
		grid.append(child.slot_data)
	return grid
