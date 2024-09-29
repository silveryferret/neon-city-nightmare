extends Camera2D

@export var dead_zone := 200
@export var lean_scale := 0.5
@export var camera_border := Vector2()
@export var mouselook := true

@onready var body = $".."

var mouse_pos

func _ready() -> void:
	camera_border.x = get_viewport_rect().size.x / 2
	camera_border.y = get_viewport_rect().size.y / 2

func _physics_process(delta: float) -> void:
	if mouselook:
		_set_camera_pos(delta)

func _set_camera_pos(delta):
	mouse_pos = get_local_mouse_position().clamp(camera_border * -1, camera_border)
	var target_position = mouse_pos * lean_scale
	
