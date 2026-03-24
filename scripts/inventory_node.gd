class_name InventoryNode extends Control

@export var inventory_data: InventoryData

const INVENTORY_SLOT := preload("uid://b4v6j80gj158n")

func _ready() -> void:
	$GridContainer.columns = inventory_data.dims[0]
	
	update_visuals()

func get_valid_slot(item: ItemData) -> int:
	var first_empty_idx = -1
	for i in range(len(inventory_data.slot_datas)):
		var slot_data = inventory_data.slot_datas[i]
		if not slot_data:
			if first_empty_idx == -1:
				first_empty_idx = i
			continue
		if slot_data.item.title == item.title: # same item
			if slot_data.amount == slot_data.item.max_stack: # already at max stack
				continue
			else:
				return i
	
	return first_empty_idx

func add_item(item: ItemData, amount: int = 1) -> bool:
	if amount == 0:
		update_visuals()
		return true
	
	var slot_idx = get_valid_slot(item)
	
	if slot_idx == -1: # no valid place
		return false
		
	if inventory_data.slot_datas[slot_idx]:
		if inventory_data.slot_datas[slot_idx].item.title == item.title:
			var remaining_amount = inventory_data.slot_datas[slot_idx].item.max_stack - inventory_data.slot_datas[slot_idx].amount
			var possible_addition = min(amount, remaining_amount)
			inventory_data.slot_datas[slot_idx].amount += possible_addition
			
			var residual_amount = amount - possible_addition
			add_item(item, residual_amount)
	else: # empty
		var data:SlotData = SlotData.new()
		data.item = item
		var possible_additions = min(amount, item.max_stack)
		data.amount = possible_additions
		inventory_data.slot_datas[slot_idx] = data
		add_item(item, amount-possible_additions)
	
	update_visuals()
	return true

func update_visuals():
	for child in $GridContainer.get_children():
		$GridContainer.remove_child(child)
		child.queue_free()
	
	for data in inventory_data.slot_datas:
		var slot = INVENTORY_SLOT.instantiate()
		slot.slot_data = data
		$GridContainer.add_child(slot)
		slot.swapped.connect(_on_slot_swap)

func _on_slot_swap(from: int, to: int): # TODO fix please
	if from == -1:
		inventory_data.slot_datas[to] = $GridContainer.get_child(to).slot_data
		return
	
	if to == -1:
		inventory_data.slot_datas[from] = null
		return

	var a = inventory_data.slot_datas[from]
	var b = inventory_data.slot_datas[to]

	if a and b and a.item.title == b.item.title:
		var transfer = min(a.amount, b.item.max_stack - b.amount)
		b.amount += transfer
		a.amount -= transfer
		
		if a.amount <= 0:
			inventory_data.slot_datas[from] = null
	
	else:
		inventory_data.slot_datas[from] = b
		inventory_data.slot_datas[to] = a

	update_visuals()

func max_additions(item: ItemData) -> int:
	# returns the maximum amount of an item that can be added
	var ans = 0
	for slot_data in inventory_data.slot_datas:
		if not slot_data:
			ans += item.max_stack
			continue
		if slot_data.item == item:
			ans += item.max_stack - slot_data.amount
	
	return ans
