extends CharacterBody2D

@onready var agent = $NavigationAgent2D
@onready var timer = $Timer
@onready var region = $"../NavigationRegion2D"

var speed = 10

var direction
var next_position

func _ready() -> void:
	timer.timeout.connect(pick_new_target)
	
	pick_new_target()
	
	next_position = agent.get_next_path_position()
	direction = (next_position - global_position).normalized()
	
func _process(_delta: float) -> void:
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		
		next_position = agent.get_next_path_position()
		direction = (next_position - global_position).normalized()
		
		if timer.is_stopped():
				timer.start()
		move_and_slide()
		return
		
	velocity = direction * speed
	move_and_slide()
	
func pick_new_target():
	var random_point = NavigationServer2D.region_get_random_point(
		region.get_rid(),
		1,
		false
	)

	agent.target_position = random_point
