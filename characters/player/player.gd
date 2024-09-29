class_name Player
extends PlatformerCharacter2D

@export var actions: PlayerInputActions
@export var camera: Camera2D
@export var lean_scale := 0.5
@export var mouselook: bool

var camera_border := Vector2()
var mouse_pos := Vector2()
var _dir := Vector2()

@export_range(0, 500, 1, "or_greater") var move_speed: float = 250
@export_range(0, 1, 0.01) var backspeed_mult: float = 0.5
@export_range(0.0, 1.0) var acceleration = 0.2
@export_range(0, -1000, 1, "or_less") var jump_force: float = -300

@export_enum(&"unarmed", &"1h", &"2h", &"melee") var hand_state = "unarmed"

@onready var _state_chart: StateChart = %StateChart
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/playback")
@onready var facing: Facing = $Facing

var reset_position: Vector2

func _ready() -> void:
	on_enter()
	camera = %Camera2D

func _physics_process(delta: float) -> void:
	move_and_slide()
	MetSys.set_player_position(global_position)

	#handle gravity
	if is_on_floor():
		_state_chart.send_event("grounded")
		velocity.y = 0
	else:
		_apply_gravity(delta)
		_state_chart.send_event("airborne")
	
	var move_blend = (velocity.x * facing.scale.x) / move_speed
	var airborne_blend = velocity.y / move_speed
	
	# set the velocity to the animation tree, so it can blend between animations
	_animation_tree["parameters/Move/blend_position"] = move_blend
	_animation_tree["parameters/Move 1h/blend_position"] = move_blend
	_animation_tree["parameters/Move 2h/blend_position"] = move_blend
	_animation_tree["parameters/Airborne/blend_position"] = airborne_blend
	_animation_tree["parameters/Airborne 1h/blend_position"] = airborne_blend
	_animation_tree["parameters/Airborne 2h/blend_position"] = airborne_blend

func _on_jump_enabled_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed(actions.jump):
		velocity.y = jump_force
		_state_chart.send_event("jump") 

func _on_double_jump_jump() -> void:
	_animation_state_machine.travel("Double Jump")

func _on_grounded_taken() -> void:
	pass
	#_animation_state_machine.travel("move")

func _on_movement_state_physics_processing(_delta: float) -> void:
	direction_input = Input.get_axis(actions.left, actions.right)
	if direction_input:
		velocity.x = lerp(velocity.x, direction_input * move_speed, acceleration)
	else:
		_apply_friction()
	camera.position = position

func _on_mouselook_movement_state_physics_processing(_delta: float) -> void:
	camera_border.x = get_viewport_rect().size.x / 3
	camera_border.y = get_viewport_rect().size.y / 3
	mouse_pos = get_local_mouse_position().clamp(camera_border * -1, camera_border)
	var target_position = position + (mouse_pos * lean_scale)
	camera.position = target_position
	if mouse_pos.x != facing.scale.x:
		direction_changed.emit(mouse_pos.x)
	
	_dir = Input.get_vector(actions.left, actions.right, actions.up, actions.down)
	var right := 1.0
	var left := -1.0
	var backspeed = move_speed * backspeed_mult
	match signf(_dir.x):
		left:
			if facing.scale.x == 1:
				velocity.x = lerp(velocity.x, _dir.x * backspeed, acceleration)
			else:
				velocity.x = lerp(velocity.x, _dir.x * move_speed, acceleration)
		right:
			if facing.scale.x == -1:
				velocity.x = lerp(velocity.x, _dir.x * backspeed, acceleration)
			else:
				velocity.x = lerp(velocity.x, _dir.x * move_speed, acceleration)
		_:
			_apply_friction()

func _on_onehand_gun_state_input(event: InputEvent) -> void:
	pass # Replace with function body.

func kill():
	# Player dies, reset the position to the entrance.
	position = reset_position
	Game.get_singleton().load_room(MetSys.get_current_room_name())

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	reset_position = position

func get_mouse_angle() -> float:
	var pos = global_position
	mouse_pos = get_global_mouse_position()
	var rads =  pos.angle_to_point(mouse_pos)
	#add 90 to the angle to rotate 0 degrees to up
	var angle = rad_to_deg(rads) + 90 
	#converts degrees so positive degrees are right and negative are left
	angle = fmod(angle + 180, 360) - 180 
	return angle
