extends Node2D

var scanpoints = []
var anomaly_1_scanpoints = []

func add_point(pos):
	scanpoints.append(pos)
	queue_redraw()

func add_anomaly_1_scan(pos):
	anomaly_1_scanpoints.append({
		"pos": pos
	})
	queue_redraw()

func _draw():
	for p in scanpoints:
		draw_circle(p, 3, Color.WHITE)

	for a in anomaly_1_scanpoints:
		draw_circle(a["pos"], 3, Color.RED)
