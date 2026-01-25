extends Node3D

const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")

@export var initial_enemies_per_wave: int = 3
@export var enemies_increment_per_wave: int = 2
@export var wave_delay: float = 3.0

var _current_wave: int = 0
var _enemies_alive: int = 0
var _is_wave_active: bool = false
var _wave_delay_timer: float = 0.0
var _spawn_points: Array[Node3D] = []
var _world: Node3D = null


func _ready() -> void:
	_world = get_parent()
	_collect_spawn_points()

	# Start first wave after a short delay
	_wave_delay_timer = 2.0


func _process(delta: float) -> void:
	if _wave_delay_timer > 0.0:
		_wave_delay_timer -= delta
		if _wave_delay_timer <= 0.0:
			_start_next_wave()


func _collect_spawn_points() -> void:
	_spawn_points.clear()
	var spawn_container := _world.get_node_or_null("SpawnPoints")
	if spawn_container:
		for child in spawn_container.get_children():
			if child is Node3D:
				_spawn_points.append(child)


func _start_next_wave() -> void:
	_current_wave += 1
	_is_wave_active = true

	var enemy_count := initial_enemies_per_wave + ((_current_wave - 1) * enemies_increment_per_wave)
	_enemies_alive = enemy_count

	# Emit wave change event
	GGF.events().emit("wave_changed", {"wave": _current_wave})

	# Spawn enemies
	for i in enemy_count:
		_spawn_enemy()


func _spawn_enemy() -> void:
	if _spawn_points.is_empty():
		return

	var enemy := ENEMY_SCENE.instantiate() as CharacterBody3D
	if not enemy:
		return

	# Pick random spawn point
	var spawn_point := _spawn_points[randi() % _spawn_points.size()]

	_world.add_child(enemy)
	enemy.global_position = spawn_point.global_position

	# Set target to closest player
	var target := _find_closest_player()
	if target and enemy.has_method("set_target"):
		enemy.set_target(target)

	# Connect to death signal
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)


func _on_enemy_died(_enemy: CharacterBody3D) -> void:
	_enemies_alive -= 1

	if _enemies_alive <= 0 and _is_wave_active:
		_is_wave_active = false
		_wave_delay_timer = wave_delay


func _find_closest_player() -> Node3D:
	# Get all players from World
	if not _world or not _world.has_method("get_closest_player"):
		return null
	return _world.get_closest_player(global_position)
