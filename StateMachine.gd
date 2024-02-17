class_name StateMachine
extends Node

var current_state
var previous_state
signal state_changed(new_state, old_state)


func change_state(new_state: Variant) -> void:
	var prev: bool = new_state == -1
	if prev:
		exit_state(current_state, previous_state)
		enter_state(previous_state, current_state)
		current_state = previous_state
		previous_state = null
	else:
		previous_state = current_state
		current_state = new_state
	if previous_state == current_state:
		return
	if previous_state != null:
		exit_state(previous_state, current_state)
	if new_state != null:
		enter_state(new_state, previous_state)

	emit_signal("state_changed", current_state, previous_state)


func enter_state(new_state: Variant, old_state: Variant) -> void:
	pass


func exit_state(old_state: Variant, new_state: Variant) -> void:
	pass


func get_transition(delta: float) -> void:
	pass


func update_state(delta: float) -> void:
	pass
