extends CharacterBody2D

@onready var agent = $NavigationAgent2D
@onready var timer = $Timer
@onready var region = get_parent().get_parent().get_node("NavigationRegion2D")

var speed = 20
var stuck_timer = 0.0
var last_position = Vector2.ZERO


func _ready() -> void:
	hide()
	timer.timeout.connect(pick_new_target)
	call_deferred("pick_new_target")


func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		if timer.is_stopped():
			timer.start()
		stuck_timer = 0.0
		move_and_slide()
		return

	if global_position.distance_to(last_position) < 1.0:
		stuck_timer += delta
		if stuck_timer >= 2.0:
			stuck_timer = 0.0
			pick_new_target()
			return
	else:
		stuck_timer = 0.0

	last_position = global_position

	var next_position = agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()


func pick_new_target() -> void:
	timer.stop()
	stuck_timer = 0.0

	var random_point = NavigationServer2D.region_get_random_point(
		region.get_rid(),
		1,
		true
	)
	agent.target_position = random_point
