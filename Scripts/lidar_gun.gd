extends Node2D

@onready var rays = $Rays.get_children()

var scan_interval = 0.1
var scan_timer = 0.0

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	scan_timer -= delta
	
	if Input.is_anything_pressed() and scan_timer <= 0:
		scan_timer = scan_interval
		
		for ray in rays:
			if ray is RayCast2D:
				ray.force_raycast_update()
				
				if ray.is_colliding():
					var body = ray.get_collider()
					
					# FIX: ensure we hit the actual enemy node
					if body is CollisionObject2D:
						body = body.get_parent()
					
					var hit_pos = ray.get_collision_point()
					
					if body.has_meta("wall"):
						print("Hit wall")
						get_tree().current_scene.get_node("Scanned").add_point(hit_pos)
					
					elif body.has_meta("anomaly_1"):
						print("Hit anomaly")
						get_tree().current_scene.get_node("Scanned").add_anomaly_1_scan(hit_pos)
