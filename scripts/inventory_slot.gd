class_name InventorySlot extends Panel

signal swapped(from: int, to: int) # -1 indicates out of scope for this slot, eg inv -> crafting

@onready var texture_rect: TextureRect = $TextureRect
@onready var amt_label: Label = $Label

var slot_data: SlotData

var pressing_shift := false
var pressing_ctrl := false

var craft_shift := false
var craft_ctrl := false

func _ready() -> void:
	if slot_data:
		texture_rect.texture = slot_data.item.texture
		amt_label.text = "x%s" % slot_data.amount
	else:
		texture_rect.texture = null
		amt_label.text = ""

func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(make_drag_preview(at_position))
	craft_shift = Input.is_action_pressed("take_half")
	craft_ctrl = Input.is_action_pressed("take_one")
	return self

func make_drag_preview(at_position: Vector2) -> Control:
	if is_empty():
		return
	var t := TextureRect.new()
	t.texture = slot_data.item.texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = self.size
	t.modulate.a = 0.5
	t.position = -at_position
	
	var label := Label.new()
	print(craft_ctrl)
	label.text = "x%d"%(1 if craft_ctrl else ceil(slot_data.amount/2) if craft_shift else slot_data.amount) # 1, half, or all
	
	t.add_child(label)
	
	var c = Control.new()
	c.add_child(t)
	
	return c

func is_empty():
	return slot_data == null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data == self:
		return false
	
	if data is InventorySlot or data is CraftingSlot or data is HotbarSlot:
		if not data.slot_data: # if an empty slot was dragged
			return false
		if self.is_empty(): # if the current slot doesn't have anything
			return true
		if self.slot_data.item.title == data.slot_data.item.title: # occupied but same item
			if self.slot_data.item.max_stack - self.slot_data.amount < (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount):
				return false # this would cause going more than max stack
			return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is InventorySlot and data.get_parent() == self.get_parent(): # Slots of same inventory
		if self.slot_data:
			if self.slot_data.item.title == data.slot_data.item.title:
				var transfer_amount = min(self.slot_data.amount + (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount), slot_data.item.max_stack)
				data.slot_data.amount -= (transfer_amount - self.slot_data.amount)
				self.slot_data.amount = transfer_amount
		else:
			self.slot_data = data.slot_data.duplicate()
			# have you gotten tired of seeing the expression yet? I have |
			#                                                      v
			self.slot_data.amount = (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount)
			data.slot_data.amount -= (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount)
		
		if data.slot_data.amount <= 0:
			data.slot_data = null
		
		self.update_visuals()
		data.update_visuals()
		
		swapped.emit(data.get_index(), self.get_index())
	elif data is CraftingSlot or data is HotbarSlot:
		if self.slot_data:
			if self.slot_data.item.title == data.slot_data.item.title:
				var transfer_amount = min(self.slot_data.amount + (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount), slot_data.item.max_stack)
				data.slot_data.amount -= (transfer_amount - self.slot_data.amount)
				self.slot_data.amount = transfer_amount
		else:
			self.slot_data = data.slot_data.duplicate()
			self.slot_data.amount = (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount)
		data.slot_data.amount -= (1 if data.craft_ctrl else ceil(data.slot_data.amount/2) if data.craft_shift else data.slot_data.amount)
		if data.slot_data.amount <= 0:
			data.slot_data = null
			
		self.update_visuals()
		data.update_visuals()
		
		swapped.emit(-1, self.get_index())

func update_visuals():
	if slot_data:
		texture_rect.texture = slot_data.item.texture
		amt_label.text = "x%s" % slot_data.amount
	else:
		texture_rect.texture = null
		amt_label.text = ""
