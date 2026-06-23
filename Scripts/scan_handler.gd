extends Node
class_name scan_handler

func handle_scan_hit(collider, collision_point: Vector2, scanned_node) -> void:
	if collider is TileMapLayer:
		var local_pos = collider.to_local(collision_point)
		var cell = collider.local_to_map(local_pos)
		var tile_data = collider.get_cell_tile_data(cell)

		if tile_data:
			var tile_type = str(tile_data.get_custom_data("type"))
			scanned_node.add_point(collision_point, tile_type)

		return

	if collider.has_meta("type"):
		scanned_node.add_point(collision_point, collider.get_meta("type"))
