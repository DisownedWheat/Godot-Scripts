extends Node

signal jump
signal move_map_changed(move_map)
signal firing(is_firing)
signal alt_firing(is_alt_firing)
signal mouse_movement(x, y)
signal sprint(is_sprinting)

var player: KinematicBody

func _ready():
	player = owner
	if not player is KinematicBody:
		push_error("Player is not kinematic body in InputBus: " + player.name)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		emit_signal("mouse_movement", event.relative.x, event.relative.y)
		return
	_handle_weapon_input(event)

	if event.is_action_pressed("sprint"):
		emit_signal("sprint", true)
	if event.is_action_released("sprint"):
		emit_signal("sprint", false)

	var move = player.move.duplicate()
	if event.is_action_pressed("forward"):
		move.forward = true
	if event.is_action_released('forward'):
		move.forward = false
	if event.is_action_pressed("back"):
		move.back = true
	if event.is_action_released('back'):
		move.back = false
	if event.is_action_pressed("left"):
		move.left = true
	if event.is_action_released('left'):
		move.left = false
	if event.is_action_pressed("right"):
		move.right = true
	if event.is_action_released('right'):
		move.right = false
	if event.is_action_pressed("jump") and player.can_jump:
		emit_signal("jump")
	if move.hash() != player.move.hash():
		emit_signal("move_map_changed", move)

func _handle_weapon_input(event):
	if event.is_action_pressed("fire"):
		emit_signal("firing", true)
	if event.is_action_released("fire"):
		emit_signal("firing", false)
	if event.is_action_pressed("alt_fire"):
		emit_signal("alt_firing", true)
	if event.is_action_released("alt_fire"):
		emit_signal("alt_firing", false)
