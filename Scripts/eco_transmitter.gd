extends StaticBody2D

@onready var ray_container = $Rays
@onready var scanned = get_tree().current_scene.get_node("Scanned")
@onready var tilemap = $"../NavigationRegion2D/Location"

var ray_count = 40
var ray_length = 100.0
var ray_origin = Vector2(0, 0)
var rays = []


var status := false:
	set(value):
		if status == value:
			return
		status = value
		await scan_region()


func _ready() -> void:
	randomize()
	_build_rays()

	await get_tree().process_frame
	_scan()


# ray setup
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


# ray scan
func _scan() -> void:
	for ray in rays:
		ray.force_raycast_update()

		if not ray.is_colliding():
			continue

		var collider = ray.get_collider()
		var collision_normal = ray.get_collision_normal()
		var collision_point = ray.get_collision_point() - collision_normal * 1.1

		_handle_hit(collider, collision_point)


# hit processing
func _handle_hit(collider, collision_point: Vector2) -> void:
	if collider is TileMapLayer:
		var local_pos = collider.to_local(collision_point)
		var cell = collider.local_to_map(local_pos)
		var tile_data = collider.get_cell_tile_data(cell)

		if tile_data:
			var region = tile_data.get_custom_data("region")
			if region != null:
				scanned.add_point(collision_point, str(region))

		return

	if collider.has_meta("type"):
		scanned.add_point(collision_point, str(collider.get_meta("type")))


# region flood scan
func scan_region() -> void:
	var start = tilemap.local_to_map(tilemap.to_local(global_position))
	var start_tile = tilemap.get_cell_tile_data(start)

	var start_region = start_tile.get_custom_data("region")

	var visited = {}
	var frontier = [start]
	var next_frontier = []

	var dirs = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	while frontier.size() > 0:
		for cell in frontier:
			if visited.has(cell):
				continue

			var tile = tilemap.get_cell_tile_data(cell)
			if tile == null:
				continue

			var region = tile.get_custom_data("region")
			if region != start_region:
				continue

			visited[cell] = true

			var base_pos = tilemap.map_to_local(cell) * 2.0

			for i in range(3):
				var offset = Vector2(
					randf_range(-16, 16),
					randf_range(-16, 16)
				) * 2.0

				scanned.add_point(base_pos + offset, str(region))

			for d in dirs:
				var n = cell + d
				if not visited.has(n):
					next_frontier.append(n)

		frontier = next_frontier
		next_frontier = []

		await get_tree().create_timer(0.05).timeout
