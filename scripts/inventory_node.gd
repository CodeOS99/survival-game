class_name InventoryNode extends Control

@export var inventory_data: InventoryData

const INVENTORY_SLOT := preload("uid://b4v6j80gj158n")

func _ready() -> void:
	$GridContainer.columns = inventory_data.dims[0]
	
	update_visuals()

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
	
	if inventory_data.slot_datas[slot_idx]:
		if inventory_data.slot_datas[slot_idx].item.title == item.item.title:
			inventory_data.slot_datas[slot_idx].amount += 1
	else:
		var data:SlotData = SlotData.new()
		data.item = item.item
		data.amount = 1
		inventory_data.slot_datas[slot_idx] = data
	
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
		slot.swapped.connect(_on_slot_swap)

func _on_slot_swap(from: int, to: int):
	if from == -1: # new item added at index to
		inventory_data.slot_datas[to] = $GridContainer.get_child(to).slot_data
	elif to == -1: # item taken away from this inv to another context:
		inventory_data.slot_datas[from] = null
	else: # slot on same inv to itself
		var a = inventory_data.slot_datas[from]
		var b = inventory_data.slot_datas[to]
		inventory_data.slot_datas[from] = inventory_data.slot_datas[to]
		inventory_data.slot_datas[to] = a
		if b:
			if a.item.title == b.item.title:
				var transfer_amount = min(a.amount + b.amount, a.item.max_stack)
				a.amount -= (transfer_amount - self.slot_data.amount)
				b.amount = transfer_amount
		else:
			b = a
		a = null
