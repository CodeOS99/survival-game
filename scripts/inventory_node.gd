class_name InventoryNode extends Control

@export var inventory_data: InventoryData

const INVENTORY_SLOT := preload("uid://b4v6j80gj158n")

func _ready() -> void:
	$GridContainer.columns = inventory_data.dims[0]
	
	for data in inventory_data.slot_datas:
		var slot = INVENTORY_SLOT.instantiate()
		slot.slot_data = data
		$GridContainer.add_child(slot)

func get_valid_slot(item) -> int:
	var first_empty_idx = -1
	for i in range(len(inventory_data.slot_datas)):
		var slot_data = inventory_data.slot_datas[i]
		if not slot_data:
			if first_empty_idx == -1:
				first_empty_idx = i
			continue
		if slot_data.item.title == item.item.title: # same item
			if slot_data.amount == slot_data.item.max_stack: # already at max stack
				continue
			else:
				return i
	
	return first_empty_idx

func add_item(item):
	var slot_idx = get_valid_slot(item)
	
	if slot_idx == -1: # no valid place
		return
	
	if inventory_data.slot_datas[slot_idx].item.title == item.item.title:
		inventory_data.slot_datas[slot_idx].amount += 1
	else:
		inventory_data.slot_datas[slot_idx].amount = 1
		inventory_data.slot_datas[slot_idx].item = item.item
	
	update_visuals()
	item.queue_free()

func update_visuals():
	for child in $GridContainer.get_children():
		$GridContainer.remove_child(child)
		child.queue_free()
	
	for data in inventory_data.slot_datas:
		var slot = INVENTORY_SLOT.instantiate()
		slot.slot_data = data
		$GridContainer.add_child(slot)
