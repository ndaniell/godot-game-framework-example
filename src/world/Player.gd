extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 6.5
@export var mouse_sensitivity: float = 0.002

# Player stats
@export var max_hp: int = 100
@export var max_shield: int = 50

var hp: int = 100
var shield: int = 50

var _yaw: float = 0.0
var _pitch: float = 0.0

# Weapon system
var _weapons: Array[Dictionary] = [
	{
		"name": "Pistol",
		"damage": 15,
		"fire_rate": 0.2,  # seconds between shots
		"pellet_count": 1,
		"spread": 0.0,
		"max_ammo": -1,  # -1 means infinite
		"current_ammo": -1,
		"is_infinite": true,
	},
	{
		"name": "Shotgun",
		"damage": 8,
		"fire_rate": 0.8,
		"pellet_count": 8,
		"spread": 0.15,  # radians
		"max_ammo": 24,
		"current_ammo": 24,
		"is_infinite": false,
	},
	{
		"name": "Rifle",
		"damage": 25,
		"fire_rate": 0.15,
		"pellet_count": 1,
		"spread": 0.0,
		"max_ammo": 60,
		"current_ammo": 60,
		"is_infinite": false,
	},
]

var _current_weapon_index: int = 0
var _time_since_last_shot: float = 0.0

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _camera: Camera3D = $SpringArm3D/Camera3D


func _ready() -> void:
	# Only the authoritative peer controls this player.
	if not _has_local_authority():
		return

	if _camera:
		_camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Initialize stats
	hp = max_hp
	shield = max_shield

	# Emit initial state to HUD
	_emit_stats_changed()
	_emit_weapon_changed()
	_emit_ammo_changed()


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

	_time_since_last_shot += delta

	# Handle weapon switching
	if Input.is_action_just_pressed("weapon_1"):
		_switch_weapon(0)
	elif Input.is_action_just_pressed("weapon_2"):
		_switch_weapon(1)
	elif Input.is_action_just_pressed("weapon_3"):
		_switch_weapon(2)

	# Handle shooting
	if Input.is_action_pressed("shoot"):
		_try_shoot()

	# Handle reload
	if Input.is_action_just_pressed("reload"):
		_try_reload()

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
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		return ui.is_menu_open("pause_menu")
	return false


func _open_pause_menu() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_menu("pause_menu", true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _close_pause_menu() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.close_menu("pause_menu")
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


func _switch_weapon(index: int) -> void:
	if index < 0 or index >= _weapons.size():
		return
	if index == _current_weapon_index:
		return

	_current_weapon_index = index
	_emit_weapon_changed()
	_emit_ammo_changed()


func _try_shoot() -> void:
	var weapon := _weapons[_current_weapon_index]

	# Check cooldown
	if _time_since_last_shot < weapon["fire_rate"]:
		return

	# Check ammo
	if not weapon["is_infinite"]:
		if weapon["current_ammo"] <= 0:
			return
		weapon["current_ammo"] -= 1
		_emit_ammo_changed()

	_time_since_last_shot = 0.0

	# Perform raycast shooting
	var pellet_count: int = weapon["pellet_count"]
	var damage: int = weapon["damage"]
	var spread: float = weapon["spread"]

	for i in pellet_count:
		_shoot_raycast(damage, spread)


func _shoot_raycast(damage: int, spread: float) -> void:
	if not _camera:
		return

	var from := _camera.global_position
	var forward := -_camera.global_transform.basis.z

	# Apply spread
	if spread > 0.0:
		var spread_x := randf_range(-spread, spread)
		var spread_y := randf_range(-spread, spread)
		var right := _camera.global_transform.basis.x
		var up := _camera.global_transform.basis.y
		forward = (forward + right * spread_x + up * spread_y).normalized()

	var to := from + forward * 1000.0

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1  # Default layer

	var result := space_state.intersect_ray(query)
	if result:
		var collider: Variant = result.get("collider")
		if collider and collider.has_method("apply_damage"):
			collider.apply_damage(damage)


func _try_reload() -> void:
	var weapon := _weapons[_current_weapon_index]

	if weapon["is_infinite"]:
		return  # Can't reload infinite ammo

	if weapon["current_ammo"] >= weapon["max_ammo"]:
		return  # Already full

	# Simple instant reload
	weapon["current_ammo"] = weapon["max_ammo"]
	_emit_ammo_changed()


func apply_damage(amount: int) -> void:
	if not _has_local_authority():
		return

	# Shield absorbs first
	if shield > 0:
		var shield_damage := mini(shield, amount)
		shield -= shield_damage
		amount -= shield_damage

	# Then HP
	if amount > 0:
		hp -= amount
		hp = maxi(hp, 0)

	_emit_stats_changed()

	if hp <= 0:
		_on_death()


func _on_death() -> void:
	# Simple respawn for now
	hp = max_hp
	shield = max_shield
	global_position = Vector3(0, 2, 0)
	_emit_stats_changed()


func _emit_stats_changed() -> void:
	(
		GGF
		. events()
		. emit(
			"player_stats_changed",
			{
				"hp": hp,
				"max_hp": max_hp,
				"shield": shield,
				"max_shield": max_shield,
			}
		)
	)


func _emit_weapon_changed() -> void:
	var weapon := _weapons[_current_weapon_index]
	(
		GGF
		. events()
		. emit(
			"player_weapon_changed",
			{
				"weapon_name": weapon["name"],
			}
		)
	)


func _emit_ammo_changed() -> void:
	var weapon := _weapons[_current_weapon_index]
	(
		GGF
		. events()
		. emit(
			"player_ammo_changed",
			{
				"current": weapon["current_ammo"],
				"max": weapon["max_ammo"],
			}
		)
	)
