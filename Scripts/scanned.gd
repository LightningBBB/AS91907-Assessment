extends Node2D

var scanpoints = []
var anomaly_1_scanpoints = []
var anomaly_2_scanpoints = []
var anomaly_3_scanpoints = []
var anomaly_4_scanpoints = []
var anomaly_5_scanpoints = []
var lorebook_scanpoints = []

func add_point(pos: Vector2) -> void:
	scanpoints.append(pos)
	queue_redraw()

func add_anomaly_1_scanpoint(pos: Vector2) -> void:
	anomaly_1_scanpoints.append(pos)
	queue_redraw()
	
	await get_tree().create_timer(2.0).timeout
	
	anomaly_1_scanpoints.erase(pos)
	queue_redraw()
	
func add_anomaly_2_scanpoint(pos: Vector2) -> void:
	anomaly_2_scanpoints.append(pos)
	queue_redraw()

func add_lorebook_scanpoint(pos: Vector2) -> void:
	lorebook_scanpoints.append(pos)
	queue_redraw()

func _draw() -> void:
	for point in scanpoints:
		draw_circle(point, 1, Color.WHITE)
	
	for point_ano1 in anomaly_1_scanpoints:
		draw_circle(point_ano1, 1, Color.RED)
	for point_ano2 in anomaly_2_scanpoints:
		draw_circle(point_ano2, 1, Color.ORANGE)
	for point_ano3 in anomaly_3_scanpoints:
		draw_circle(point_ano3, 1, Color.RED)
	for point_ano4 in anomaly_4_scanpoints:
		draw_circle(point_ano4, 1, Color.RED)
	for point_ano5 in anomaly_5_scanpoints:
		draw_circle(point_ano5, 1, Color.RED)
		
	for point_lorebook in lorebook_scanpoints:
		draw_circle(point_lorebook, 1, Color.GREEN)
