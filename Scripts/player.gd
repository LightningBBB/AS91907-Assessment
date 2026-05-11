extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	
	velocity.x = SPEED * direction.x
	velocity.y = SPEED * direction.y
	move_and_slide()
