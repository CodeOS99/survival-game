extends Node3D

var needs_hotbar_ref = true
var hotbar_ref: HotbarSlot
var using = false
var can_delete: bool = false

var hunger_cost = -5 # not sure if this is a good way to do this
# certainly the one which uses the smallest amount of lines :P

func use() -> void:
	if $BreadUsable/AnimationPlayer.is_playing():
		return
	using = true
	$BreadUsable/AnimationPlayer.play("lmb")
	hotbar_ref.slot_data.amount -= 1
	hotbar_ref.update_visuals()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "lmb":
		using = false
		if hotbar_ref.slot_data and hotbar_ref.slot_data.amount <= 0:
			hotbar_ref.slot_data = null
			hotbar_ref.update_visuals()
			self.queue_free()

func reset():
	pass
