extends StaticBody2D

@onready var ray_container = $Rays
@onready var scanned = get_tree().current_scene.get_node("Scanned")
@onready var scan_handler_local = scan_handler.new()
@onready var tilemap = get_parent().get_node("NavigationRegion2D/TileMapLayer")

var ray_count = 40
var ray_length = 100.0
var ray_origin = Vector2(0, 0)
var rays = []

func _ready() -> void:
	randomize()
	_build_rays()
	await get_tree().process_frame
	_scan()
	activate()

func _build_rays() -> void:
	for child in ray_container.get_children():
		child.queue_free()

	rays.clear()

	for i in ray_count:
		var angle = TAU * float(i) / ray_count

		var ray = RayCast2D.new()
		ray.position = ray_origin
		ray.target_position = Vector2(cos(angle), sin(angle)) * ray_length
		ray.collide_with_areas = true
		ray.enabled = true

		ray_container.add_child(ray)
		rays.append(ray)

func _scan() -> void:
	for ray in rays:
		ray.force_raycast_update()

		if not ray.is_colliding():
			continue

		var collider = ray.get_collider()
		var collision_normal = ray.get_collision_normal()
		var collision_point = ray.get_collision_point() - collision_normal * 1.1

		scan_handler_local.handle_scan_hit(collider, collision_point, scanned)

func activate():
	var start = tilemap.local_to_map(tilemap.to_local(global_position))

	var start_source = tilemap.get_cell_source_id(start)
	var start_atlas = tilemap.get_cell_atlas_coords(start)

	if start_source == -1:
		print("no tile")
		return

	var DIRS = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	var visited = {}
	var stack = [start]
	var edges = {}

	while stack.size() > 0:
		var cell = stack.pop_back()

		if visited.has(cell):
			continue

		var source_id = tilemap.get_cell_source_id(cell)
		var atlas = tilemap.get_cell_atlas_coords(cell)

		# only stay in SAME tile type
		if source_id != start_source or atlas != start_atlas:
			continue

		visited[cell] = true

		var is_edge = false

		for d in DIRS:
			var n = cell + d

			var n_source = tilemap.get_cell_source_id(n)
			var n_atlas = tilemap.get_cell_atlas_coords(n)

			# boundary condition = different tile OR empty
			if n_source != start_source or n_atlas != start_atlas:
				is_edge = true
			else:
				if not visited.has(n):
					stack.append(n)

		if is_edge:
			edges[cell] = true

			var dot_parent = get_tree().current_scene

			var dot = ColorRect.new()
			dot.color = Color.RED
			dot.size = Vector2(5, 5)

			var world_pos = tilemap.map_to_local(cell)
			dot.position = (world_pos - Vector2(2.5, 2.5)) * 2.0

			dot_parent.add_child(dot)

	print("region size:", visited.size())
	print("edge tiles:", edges.size())
