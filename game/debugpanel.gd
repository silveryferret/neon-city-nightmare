extends Control

@export var character: PlatformerCharacter2D
@onready var state_chart = %Player/StateChart
@onready var camera = %Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%mouselook.button_pressed = character.mouselook

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%"velocity vec".text = str(round(character.velocity))
	%camera_pos.text = str(round(camera.position))
	%mouse_pos.text = str(round(character.get_local_mouse_position()))
	%mouse_angle.text = str(round(snapped(character.get_mouse_angle() * character.scale.x, 45)))

func _on_mouselook_pressed() -> void:
	character.mouselook = !character.mouselook
	%mouselook.button_pressed = character.mouselook
	if character.mouselook:
		state_chart.send_event("mouselook_on")
	else:
		state_chart.send_event("mouselook_off")
	state_chart.set_expression_property("mouselook_enabled", character.mouselook)


func _on_option_button_item_selected(index: int) -> void:
	var state
	match index:
		0:
			state = "unarmed"
			state_chart.set_expression_property("hand_state", "unarmed")
			state_chart.send_event("unequip")
		1:
			state = "melee"
			state_chart.set_expression_property("hand_state", "melee")
			state_chart.send_event("equip melee")
		2:
			state = "1h"
			state_chart.set_expression_property("hand_state", "1h")
			state_chart.send_event("equip_1h")

		3:
			state = "2h"
			state_chart.set_expression_property("hand_state", "2h")
			state_chart.send_event("equip_2h")
	character.hand_state = state
