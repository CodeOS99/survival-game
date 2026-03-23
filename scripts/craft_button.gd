extends Button

func _on_pressed() -> void:
	# no need to add any check since if it is enabled, a valid recipe is present
	var recipe: CraftingRecipe = $"../../..".curr_valid_recipe
	
	if not recipe:
		return
	
	if recipe.result_amount > Globals.player.inventory.max_additions(recipe.result):
		return # exceeding max addition
	
	for i in range(len(recipe.items)):
		var pos = recipe.pos[i]
		var j = pos.x + pos.y * $"../../..".SIDE_LENGTH +  $"../../..".curr_recipe_start
		$"../GridContainer".get_child(j).remove_item(recipe.amounts[i])
	
	Globals.player.inventory.add_item(recipe.result, recipe.result_amount)
