extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SHIFT_SPEED = -100


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	if not Input.is_action_pressed("sneak"):
		velocity.x = SPEED * direction.x
		velocity.y = SPEED * direction.y
		move_and_slide()
	else:
		velocity.x = (SPEED + SHIFT_SPEED) * direction.x
		velocity.y = (SPEED + SHIFT_SPEED) * direction.y
		move_and_slide()
