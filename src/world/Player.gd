extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 6.5
@export var mouse_sensitivity: float = 0.002

var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	# Only the authoritative peer controls this player.
	if not is_multiplayer_authority():
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, -1.2, 1.2)
		rotation.y = _yaw

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var dir := Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		dir.z -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.z += 1.0
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0

	dir = dir.normalized()
	var basis := Basis(Vector3.UP, rotation.y)
	var wish := basis * dir

	velocity.x = wish.x * move_speed
	velocity.z = wish.z * move_speed

	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity

	move_and_slide()
