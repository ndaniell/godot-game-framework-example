extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 6.5
@export var mouse_sensitivity: float = 0.002

var _yaw: float = 0.0
var _pitch: float = 0.0

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _camera: Camera3D = $SpringArm3D/Camera3D


func _ready() -> void:
	# Only the authoritative peer controls this player.
	if not _has_local_authority():
		return

	if _camera:
		_camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not _has_local_authority():
		return

	if _is_pause_menu_open():
		# When the pause menu is open, ignore player look input (UI handles input first).
		if event.is_action_pressed("ui_cancel") or _is_escape_pressed(event):
			_close_pause_menu()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel") or _is_escape_pressed(event):
		_open_pause_menu()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, -1.2, 1.2)
		rotation.y = _yaw
		if _spring_arm:
			_spring_arm.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	if not _has_local_authority():
		return
	if _is_pause_menu_open():
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
	var move_basis := Basis(Vector3.UP, rotation.y)
	var wish := move_basis * dir

	velocity.x = wish.x * move_speed
	velocity.z = wish.z * move_speed

	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity

	move_and_slide()


func _is_pause_menu_open() -> bool:
	var ui := GGF.get_manager(&"UIManager")
	if ui and ui.has_method("is_menu_open"):
		var val: Variant = ui.call("is_menu_open", "pause_menu")
		return val is bool and (val as bool)
	return false


func _open_pause_menu() -> void:
	var ui := GGF.get_manager(&"UIManager")
	if ui and ui.has_method("open_menu"):
		ui.call("open_menu", "pause_menu", true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _close_pause_menu() -> void:
	var ui := GGF.get_manager(&"UIManager")
	if ui and ui.has_method("close_menu"):
		ui.call("close_menu", "pause_menu")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _is_escape_pressed(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	var key_event := event as InputEventKey
	return key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE


func _has_local_authority() -> bool:
	# During disconnect/scene teardown, `multiplayer_peer` can be null for a frame.
	# `is_multiplayer_authority()` may query a unique id, which errors without a peer.
	if multiplayer.multiplayer_peer == null:
		return false
	return is_multiplayer_authority()
