extends KinematicBody2D


export var speed := 400.0
export var can_accelerate := false
export var acceleration := 800.0
export var friction := 1_000.0

var velocity := Vector2()


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if can_accelerate:
		if input == Vector2.ZERO:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		else:
			velocity = velocity.move_toward(input * speed, acceleration * delta)
	else:
		velocity = input * speed
	velocity = move_and_slide(velocity)
