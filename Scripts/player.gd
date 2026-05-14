extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const SHIFT_SPEED = -100

@export var flicker_speed = 20
@export var point_size = 1
@export var body_size = 20
@export var max_points = 25
@export var gun_size = Vector2(300, 100)

var points_body = []


func _ready() -> void:
	randomize()
	
	for i in max_points:
		points_body.append({
			"position": Vector2(
				randf_range(-body_size, body_size),
				randf_range(-body_size, body_size)
			),
			"visible": randf() > 0.5,
			"timer": randf()
		})
	
	queue_redraw()

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	if not Input.is_action_pressed("sneak"):
		velocity.x = SPEED * direction.x
		velocity.y = SPEED * direction.y
		move_and_slide()
	else:
		velocity.x = (SPEED + SHIFT_SPEED) * direction.x
		velocity.y = (SPEED + SHIFT_SPEED) * direction.y
		move_and_slide()

	for p in points_body:
		p["timer"] -= delta
		
		if p["timer"] <= 0:
			p["visible"] = randf() > 0.5
			p["timer"] = randf_range(0.01, flicker_speed)
		
	queue_redraw()
	
func _draw():
	for p in points_body:
		if p["visible"] == true:
			draw_circle(p["position"], point_size, Color.WHITE)
