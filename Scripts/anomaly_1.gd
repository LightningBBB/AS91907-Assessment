extends CharacterBody2D

@onready var agent = $NavigationAgent2D
@onready var timer = $Timer
@onready var region = $"../AnomalySpawn"

var speed = 10

func _ready() -> void:
	timer.timeout.connect(pick_new_target)
	pick_new_target()

func _physics_process(_delta: float) -> void:
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		
		if timer.is_stopped():
			timer.start()
		
		move_and_slide()
		return
	
	var next_position = agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()

func pick_new_target():
	timer.stop() # IMPORTANT
	
	var random_point = NavigationServer2D.region_get_random_point(
		region.get_rid(),
		1,
		false
	)

	agent.target_position = random_point
