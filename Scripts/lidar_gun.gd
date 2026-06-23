extends Node2D

@onready var ray_container = $Rays
@onready var scanned = get_tree().current_scene.get_node("Scanned")
@onready var scan_handler_local = scan_handler.new()
@onready var beep = $beep

var ray_count = 11
var ray_length = 525.0
var ray_origin = Vector2(0, 0)
var cone_angle = 30.0
var rays_per_scan = 40
var scan_cooldown = 4.0
var cooldown_timer = 0.0
var scanning = false
var rays = []


func _ready() -> void:
	randomize()
	_build_rays()


# ray setup
func _build_rays() -> void:
	for child in ray_container.get_children():
		child.queue_free()

	rays.clear()

	for i in ray_count:
		var angle = deg_to_rad(
			lerp(-cone_angle, cone_angle, float(i) / (ray_count - 1))
		)

		var ray = RayCast2D.new()
		ray.position = ray_origin
		ray.target_position = Vector2(cos(angle), sin(angle)) * ray_length
		ray.collide_with_areas = true
		ray.enabled = true

		ray_container.add_child(ray)
		rays.append(ray)


# aim + cooldown
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	cooldown_timer -= delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scan") and cooldown_timer <= 0 and not scanning:
		cooldown_timer = scan_cooldown
		_scan()


# scan execution
func _scan() -> void:
	scanning = true

	for i in rays_per_scan:
		if Global.fuel <= 0:
			break

		var shuffled = rays.duplicate()
		shuffled.shuffle()

		var batch = shuffled.slice(0, 2)

		for ray in batch:
			ray.force_raycast_update()

			if not ray.is_colliding():
				continue

			var collider = ray.get_collider()
			var collision_normal = ray.get_collision_normal()
			var collision_point = ray.get_collision_point() - collision_normal * 1.1

			scan_handler_local.handle_scan_hit(collider, collision_point, scanned)

		beep.play()
		await get_tree().create_timer(0.05).timeout

		if Global.fuelbonus > 0:
			Global.fuelbonus -= 0.25
		else:
			Global.fuel -= 0.25

	scanning = false
