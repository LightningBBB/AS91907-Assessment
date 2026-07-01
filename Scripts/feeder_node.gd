extends StaticBody2D

@onready var ray_container: Node2D = $Rays
@onready var scanned: Node = get_tree().current_scene.get_node("Scanned")
@onready var tilemap: TileMapLayer = $"../NavigationRegion2D/Location"
@onready var overlay_tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")

@export var ray_count: int = 40
@export var ray_length: float = 100.0

var ray_origin: Vector2 = Vector2.ZERO
var rays: Array[RayCast2D] = []

var status: bool = false:
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


# Ray setup
func _build_rays() -> void:
	for child in ray_container.get_children():
		child.queue_free()

	rays.clear()

	for i: int in ray_count:
		var angle: float = TAU * float(i) / ray_count
		var ray: RayCast2D = RayCast2D.new()

		ray.position = ray_origin
		ray.target_position = Vector2(cos(angle), sin(angle)) * ray_length
		ray.collide_with_areas = true
		ray.enabled = true

		ray_container.add_child(ray)
		rays.append(ray)


# Ray scan
func _scan() -> void:
	for ray: RayCast2D in rays:
		ray.force_raycast_update()

		if not ray.is_colliding():
			continue

		var collider: Object = ray.get_collider()
		var collision_normal: Vector2 = ray.get_collision_normal()
		var collision_point: Vector2 = ray.get_collision_point() - collision_normal * 1.1

		_handle_hit(collider, collision_point)


# Hit processing
func _handle_hit(collider: Object, collision_point: Vector2) -> void:
	if collider is TileMapLayer:
		var local_pos: Vector2 = collider.to_local(collision_point)
		var cell: Vector2i = collider.local_to_map(local_pos)
		var tile_data: TileData = collider.get_cell_tile_data(cell)

		if tile_data:
			var region: Variant = tile_data.get_custom_data("region")
			if region != null:
				scanned.add_point(collision_point, str(region))

		return

	if collider.has_meta("type"):
		scanned.add_point(collision_point, str(collider.get_meta("type")))


# Region flood scan
func scan_region() -> void:
	var start: Vector2i = tilemap.local_to_map(tilemap.to_local(global_position))
	var start_tile: TileData = tilemap.get_cell_tile_data(start)
	var start_region: Variant = start_tile.get_custom_data("region")

	var visited: Dictionary = {}
	var frontier: Array[Vector2i] = [start]
	var next_frontier: Array[Vector2i] = []

	var dirs: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	while frontier.size() > 0:
		for cell: Vector2i in frontier:
			if visited.has(cell):
				continue

			var tile: TileData = tilemap.get_cell_tile_data(cell)
			if tile == null:
				continue

			var region: Variant = tile.get_custom_data("region")
			if region != start_region:
				continue

			visited[cell] = true
			scanned.mark_cell_activated(cell, str(region))

			# Skip first three atlas columns, but allow empty overlay cells.
			var source_id: int = overlay_tilemap.get_cell_source_id(cell)
			if source_id == -1 or overlay_tilemap.get_cell_atlas_coords(cell).x > 2:
				var base_pos: Vector2 = tilemap.map_to_local(cell) * 2.0

				for i: int in range(1):
					var offset: Vector2 = Vector2(
						randf_range(-16, 16),
						randf_range(-16, 16)
					) * 2.0

					scanned.add_point(base_pos + offset, str(region))

			for d: Vector2i in dirs:
				var n: Vector2i = cell + d
				if not visited.has(n):
					next_frontier.append(n)

		frontier = next_frontier
		next_frontier = []

		await get_tree().create_timer(0.05).timeout
