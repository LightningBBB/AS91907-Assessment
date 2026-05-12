extends Node2D

var scanpoints = []
var anomaly_1_scanpoints = []

func add_point(pos: Vector2) -> void:
	scanpoints.append(pos)
	queue_redraw()

func add_anomaly_1_scan(pos: Vector2) -> void:
	anomaly_1_scanpoints.append(pos)
	queue_redraw()

func _draw() -> void:
	for p in scanpoints:
		draw_circle(p, 1, Color.WHITE)
	for a in anomaly_1_scanpoints:
		draw_circle(a, 1, Color.RED)
