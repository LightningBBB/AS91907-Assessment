extends Node2D

@onready var ray_container = $Rays
@onready var scanned = get_tree().current_scene.get_node("Scanned")
@onready var beep = $beep

@export var flicker_speed = 20
@export var point_size = 1
@export var max_points = 25

const GUN_WIDTH := 50.0
const GUN_HEIGHT := 16.0

var ray_count = 11
var ray_length = 525.0
var ray_origin = Vector2(0, 0)
var cone_angle = 30.0
var rays_per_scan = 40
var scan_cooldown = 4.0
var cooldown_timer = 0.0
var scanning = false
var rays = []
var points_gun = []

func _ready() -> void:
	randomize()

	for i in max_points:
		points_gun.append({
			"position": Vector2(
				randf_range(0, GUN_WIDTH),
				randf_range(-GUN_HEIGHT * 0.5, GUN_HEIGHT * 0.5)
			),
			"visible": randf() > 0.5,
			"timer": randf()
		})

	_build_rays()

func _build_rays() -> void:
	for child in ray_container.get_children():
		child.queue_free()
	rays.clear()

	for i in ray_count:
		var angle = deg_to_rad(lerp(-cone_angle, cone_angle, float(i) / (ray_count - 1)))
		var ray = RayCast2D.new()
		ray.position = ray_origin
		ray.target_position = Vector2(cos(angle), sin(angle)) * ray_length
		ray.collide_with_areas = true
		ray.enabled = true
		ray_container.add_child(ray)
		rays.append(ray)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	cooldown_timer -= delta

	for p in points_gun:
		p["timer"] -= delta

		if p["timer"] <= 0:
			p["visible"] = randf() > 0.5
			p["timer"] = randf_range(0.01, flicker_speed)

	queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scan") and cooldown_timer <= 0 and not scanning:
		cooldown_timer = scan_cooldown
		_scan()

func _scan() -> void:
	scanning = true

	for i in rays_per_scan:
		var shuffled = rays.duplicate()
		shuffled.shuffle()

		for ray in shuffled.slice(  0, 2):
			ray.force_raycast_update()

			if not ray.is_colliding():
				continue

			var collider = ray.get_collider()
			var collision_point = ray.get_collision_point()
			var tile_data = collider.get_cell_tile_data(collision_point)

			var tile_type = tile_data.get_custom_data("type")
			scanned.add_point(collision_point, tile_type)
			# wall anoamly_1 anoamly_2 anoamly_3 lore
		await get_tree().create_timer(0.05).timeout

	scanning = false

func _draw():
	for p in points_gun:
		if p["visible"] == true:
			draw_circle(p["position"], point_size, Color.WHITE)
