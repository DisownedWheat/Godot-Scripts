extends StateMachine

@export
var jump_curve: Curve
@export
var walk_speed: int = 1000

var player: PlayerEntity
var jump_counter: float = 0
var jump_timer: float = 1
var is_moving: bool = false
var jump_direction: Vector3
var jump_timer_node: Timer

enum States {
	IDLE,
	MOVE,
	JUMP,
	FALL
}

@onready
var current_gravity: float = jump_curve.interpolate_baked(1)

func _ready() -> void:
	player = owner
	call_deferred("_set_state", States.IDLE)
	jump_timer_node = Timer.new()
	jump_timer_node.wait_time = 0.5
	jump_timer_node.one_shot = true
	add_child(jump_timer_node)

func _physics_process(delta: float) -> void:
	var velocity = Vector3()
	match state:
		States.FALL:
			jump_counter += delta
			velocity = jump_direction * walk_speed * delta
			if player.is_on_ceiling():
				jump_counter += 0.15
			_update_current_gravity()
			if jump_timer_node.is_stopped() and player.is_on_floor():
				call_deferred("_set_state", States.MOVE)
		States.JUMP:
			jump_counter += delta
			velocity = jump_direction * walk_speed * delta
			if player.is_on_ceiling():
				jump_counter += 0.15
			_update_current_gravity()
		_:
			if jump_timer_node.is_stopped() and not player.is_on_floor():
				_set_state(States.FALL)
			var move_vector: Vector3 = _build_move_vector()
			if move_vector == Vector3.ZERO and state == States.MOVE:
				_set_state(States.IDLE)
			if move_vector != Vector3.ZERO and state != States.MOVE:
				_set_state(States.MOVE)
			velocity = move_vector.rotated(Vector3.UP, player.camera_holder.rotation.y) * walk_speed * delta

	velocity.y = current_gravity
	player.move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(70), true)

func jump() -> void:
	match state:
		States.FALL:
			return
		States.JUMP:
			return
		_:
			jump_counter = 0
			current_gravity = jump_curve.interpolate_baked(0)
			_set_state(States.JUMP)

# TODO: Make remotesync
func _update_current_gravity() -> void:
	current_gravity = jump_curve.interpolate_baked(jump_counter / jump_timer)
	if current_gravity < 0 and not player.is_on_floor():
		_set_state(States.FALL)

# TODO: Make remotesync
func _enter_state(new_state, old_state) -> void:
	match new_state:
		States.JUMP:
			jump_direction = _build_move_vector().rotated(Vector3.UP, player.camera_holder.rotation.y)
			jump_timer_node.start()
		States.FALL:
			return
		_:
			jump_direction = Vector3.ZERO

# TODO: Make remotesync
func _exit_state(old_state, new_state) -> void:
	pass

func _build_move_vector() -> Vector3:
	var velocity = Vector3()
	if player.move.forward:
		velocity.z -= 1
	if player.move.back:
		velocity.z += 1
	if player.move.right:
		velocity.x += 1
	if player.move.left:
		velocity.x -= 1
	return velocity
