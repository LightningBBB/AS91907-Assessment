extends Node2D

var scanpoints = {
	"wall": [],
	"anomaly_1": [],
	"anomaly_2": [],
	"anomaly_3": [],
	"anomaly_4": [],
	"anomaly_5": [],
	"lore_book": [],
	"credit": [],
	"structure": [],
	"feeder_node": [],
	"A0": [],
	"A1": [],
	"B1": [],
	"B2": [],
	"C0": [],
	"D0": [],
	"D1": [],
	"GΩ": []
}

const COLORS = {
	"wall": Color("#E6E6E6"),
	"anomaly_1": Color("#E07A7A"),
	"anomaly_2": Color("#F09A5C"),
	"anomaly_3": Color("#E05C7A"),
	"anomaly_4": Color("#C84A4A"),
	"anomaly_5": Color("#9A2F2F"),
	"lore_book": Color("#7FD6B0"),
	"credit": Color("#D6C27A"),
	"structure": Color("#7FA6D6"),
	"feeder_node": Color("#B08AD6"),
	"A0": Color("#7FC9A0"),
	"A1": Color("#57A883"),
	"B1": Color("#C2B06F"),
	"B2": Color("#A08A55"),
	"C0": Color("#6F97C9"),
	"D0": Color("#C96F6F"),
	"D1": Color("#C8573A"),
	"GΩ": Color("#9A74E6")
}

var dot_sizes = {
	"wall": 1.0,
	"anomaly_1": 1.0,
	"anomaly_2": 1.0,
	"anomaly_3": 1.0,
	"anomaly_4": 1.0,
	"anomaly_5": 1.0,
	"lore_book": 1.0,
	"credit": 1.0,
	"structure": 1.0,
	"feeder_node": 1.0,
	"A0": 0.25,
	"A1": 0.25,
	"B1": 0.25,
	"B2": 0.25,
	"C0": 0.25,
	"D0": 0.25,
	"D1": 0.25,
	"GΩ": 0.25
}

var activated_cells: Dictionary = {}  # Vector2i -> String (region code)


func mark_cell_activated(cell: Vector2i, region: String) -> void:
	activated_cells[cell] = region


func get_region_at(cell: Vector2i) -> String:
	return activated_cells.get(cell, "")


func add_point(collision_point: Vector2, collider) -> void:
	var key = str(collider)

	if not scanpoints.has(key):
		return

	scanpoints[key].append({
		"pos": collision_point,
		"size": dot_sizes.get(key, 1.0)
	})

	queue_redraw()

	if key == "anomaly_1":
		await get_tree().create_timer(2.0).timeout

		if scanpoints[key].size() > 0:
			scanpoints[key].pop_front()
			queue_redraw()


func _draw() -> void:
	for key in scanpoints:
		for data in scanpoints[key]:
			var size = max(data["size"] * 2.0, 1.0)

			draw_rect(
				Rect2(
					data["pos"] - Vector2(size, size) * 0.5,
					Vector2(size, size)
				),
				COLORS.get(key, Color.WHITE)
			)
