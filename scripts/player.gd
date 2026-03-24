class_name Player extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8*2/1.25
const SENSITIVITY = 0.004

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8*2

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var right_hand_holding = $Head/Camera3D/Hands/HandRight/Holding
@onready var hotbar: Hotbar = $HUD/Hotbar
@onready var inventory: InventoryNode = $HUD/Inv/InventoryNode
@onready var crafting_menu: Control = $HUD/Inv/CraftingMenu

# for additional bobbing things
var additional_bobbers: Array[Node3D] = []
var bob_freqs = {}
var bob_amps = {}

var can_turn := true

var updated_held_once = false
var curr_held_item: ItemData = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.player = self

func _unhandled_input(event):
	if event is InputEventMouseMotion and can_turn:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _process(delta: float) -> void:
	if can_turn:
		if Input.is_action_just_pressed("use_tool"):
			if right_hand_holding.get_child(0):
				if right_hand_holding.get_child(0).is_in_group("usable"):
					if not right_hand_holding.get_child(0).using:
						right_hand_holding.get_child(0).use()
		elif Input.is_action_just_released("use_tool"):
			if right_hand_holding.get_child(0):
				if right_hand_holding.get_child(0).is_in_group("usable"):
					right_hand_holding.get_child(0).reset()
	
	update_held_item()
	
	if Input.is_action_just_pressed("toggle_inventory"):
		$HUD/Inv.visible = not $HUD/Inv.visible
		if $HUD/Inv.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			can_turn = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			can_turn = true

func update_held_item():
	var item := hotbar.get_active_item()
	
	if curr_held_item == item:
		return
	
	if item == null:
		if curr_held_item:
			$Head/Camera3D/Hands/HandRight/Holding.get_child(0).queue_free()
			curr_held_item = item
			
	if item:
		if updated_held_once:
			$Head/Camera3D/Hands/HandRight/Holding.get_child(0).queue_free()
		
		var instance = item.mesh.instantiate()
		instance.scale = Vector3(item.mesh_scale, item.mesh_scale, item.mesh_scale)
		$Head/Camera3D/Hands/HandRight/Holding.add_child(instance)
		$Head/Camera3D/Hands/HandRight/Holding.move_child(instance, 0)
		
		if not updated_held_once:
			updated_held_once = true
	
	curr_held_item = item

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func shake_camera(period: float = 0.3, magnitude: float = 0.01):
	camera.period = period
	camera.magnitude = magnitude
	camera.should_shake = true
