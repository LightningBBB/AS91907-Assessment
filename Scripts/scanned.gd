extends Node2D

var scanpoints = []
var anomaly_1_scanpoints = []
var anomaly_2_scanpoints = []
var anomaly_3_scanpoints = []
var anomaly_4_scanpoints = []
var anomaly_5_scanpoints = []
var lorebook_scanpoints = []
var structure_scanpoints = []
var credit_scanpoints = []

func add_point(collision_point: Vector2, collider) -> void:
	if collider == "wall":
		scanpoints.append(collision_point)
		queue_redraw()
	
	elif collider == "lore_book":
		lorebook_scanpoints.append(collision_point)
		queue_redraw()
		
	elif collider == "credit":
		credit_scanpoints.append(collision_point)
		queue_redraw()
		
	elif collider == "anomaly_1":
		anomaly_1_scanpoints.append(collision_point)
		queue_redraw()
		
		await get_tree().create_timer(2.0).timeout
		
		anomaly_1_scanpoints.erase(collision_point)
		queue_redraw()
		
	elif collider == "anomaly_2":
		anomaly_2_scanpoints.append(collision_point)
		queue_redraw()
		
	elif collider == "structure":
		structure_scanpoints.append(collision_point)
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
		
	for point_credit in credit_scanpoints:
		draw_circle(point_credit, 1, Color.GOLD)
		
	for point_structure in structure_scanpoints:
		draw_circle(point_structure, 1, Color.BLUE)
