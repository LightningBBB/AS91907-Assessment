extends Node2D

var scanpoints = {
	"wall": [],
	"anomaly_1": [],
	"anomaly_2": [],
	"anomaly_3": [],
	"anomaly_4": [],
	"anomaly_5": [],
	"lore_book": [],
	"structure": [],
	"credit": [],
	"eco_transmitter": []
}

var colors = {
	"wall": Color.WHITE,
	"anomaly_1": Color.RED,
	"anomaly_2": Color.ORANGE,
	"anomaly_3": Color.RED,
	"anomaly_4": Color.RED,
	"anomaly_5": Color.RED,
	"lore_book": Color.GREEN,
	"credit": Color.GOLD,
	"structure": Color.BLUE,
	"eco_transmitter": Color.HOT_PINK
}

func add_point(collision_point: Vector2, collider) -> void:
	if not scanpoints.has(collider):
		return

	scanpoints[collider].append(collision_point)
	queue_redraw()

	if collider == "anomaly_1":
		await get_tree().create_timer(2.0).timeout
		scanpoints[collider].erase(collision_point)
		queue_redraw()

func _draw() -> void:
	for key in scanpoints:
		for point in scanpoints[key]:
			draw_circle(point, 1, colors.get(key, Color.WHITE))
