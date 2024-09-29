class_name PlatformerCharacter2D
extends CharacterBody2D

@export_range(0.0, 1.0) var friction: float = 0.2

signal direction_changed(direction_input: float)
var direction_input : float :
	set(value):
		if direction_input == value:
			return

		direction_input = value
		direction_changed.emit(direction_input)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _apply_friction():
	velocity.x = lerp(velocity.x, 0.0, friction)

func _apply_gravity(delta):
	velocity.y += gravity * delta
