extends Node3D

const SIZE := 32
const SCALE = 1.0
const HEIGHT_SCALE := 5.0
const GENERATION_DISTANCE = 1

var noise: FastNoiseLite
var chunks = {}
var last_player_chunk := Vector2i(999999, 999999)

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.01 # lower for smoother
	
	generate_chunks()

func _process(delta: float) -> void:
	var player_pos = Globals.player.position
	var current_chunk = Vector2i(
		floor(player_pos.x/SIZE),
		floor(player_pos.z/SIZE)
	)
	
	if current_chunk != last_player_chunk:
		last_player_chunk = current_chunk
		generate_chunks()

func generate_chunks():
	var player_pos = Globals.player.position
	var player_chunk_x = floor(player_pos.x / SIZE)
	var player_chunk_z = floor(player_pos.z / SIZE)
	
	for x in range(player_chunk_x - GENERATION_DISTANCE, player_chunk_x + GENERATION_DISTANCE + 1):
		for z in range(player_chunk_z - GENERATION_DISTANCE, player_chunk_z + GENERATION_DISTANCE + 1):
			var key = Vector2i(x, z)
			if not chunks.has(key): # generate onlly if not already generated
				var chunk = generate_chunk(x, z)
				chunks[key] = chunk

func generate_chunk(chunk_x: int, chunk_z: int) -> Node3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(SIZE):
		for z in range(SIZE):
			add_quad(st, x, z, chunk_x, chunk_z)
	
	st.generate_normals()
	var mesh = st.commit()
	
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, material)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	
	mesh_instance.position = Vector3( # set chunk position
		chunk_x * SIZE,
		0,
		chunk_z * SIZE
	)
	
	# collision
	var body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	collision.shape = mesh.create_trimesh_shape()
	body.add_child(collision)
	mesh_instance.add_child(body)
	
	add_child(mesh_instance)
	
	return mesh_instance

func add_quad(st: SurfaceTool, x: int, z: int, chunk_x: int, chunk_z: int):
	var world_x = x + chunk_x * SIZE
	var world_z = z + chunk_z * SIZE
	
	var h1 = noise.get_noise_2d(world_x, world_z) * HEIGHT_SCALE
	var h2 = noise.get_noise_2d(world_x+1, world_z) * HEIGHT_SCALE
	var h3 = noise.get_noise_2d(world_x, world_z+1) * HEIGHT_SCALE
	var h4 = noise.get_noise_2d(world_x+1, world_z+1) * HEIGHT_SCALE
	
	var v1 = Vector3(x, h1, z) * SCALE
	var v2 = Vector3(x+1, h2, z) * SCALE
	var v3 = Vector3(x, h3, z+1) * SCALE
	var v4 = Vector3(x+1, h4, z+1) * SCALE
	
	# Triangle 1
	st.set_color(get_color(h1))
	st.add_vertex(v1)

	st.set_color(get_color(h2))
	st.add_vertex(v2)

	st.set_color(get_color(h3))
	st.add_vertex(v3)

	# Triangle 2
	st.set_color(get_color(h2))
	st.add_vertex(v2)

	st.set_color(get_color(h4))
	st.add_vertex(v4)

	st.set_color(get_color(h3))
	st.add_vertex(v3)

func get_color(height: float) -> Color:
	if height < -2:
		return Color(0.0, 0.742, 0.742, 1.0)
	elif height < 0:
		return Color(1.0, 0.8, 0.435, 1.0)
	elif height < 2:
		return Color(0.2, 0.8, 0.2)
	elif height < 4:
		return Color(0.3, 0.3, 0.3, 1.0)
	else:
		return Color(0.0, 0.396, 0.0, 1.0)
