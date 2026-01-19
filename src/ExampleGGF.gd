extends "res://addons/godot_game_framework/addons/godot_game_framework/GGF.gd"

const MANAGER_NODE_PREFIX := "GGF_"


func _bootstrap() -> void:
	# Copy the framework’s bootstrap ordering, but inject our project-owned GameManager.
	# This keeps the submodule pristine while letting the example own game flow.
	if _bootstrapped:
		return
	_bootstrapped = true

	_load_type_scripts()

	_ensure_manager(
		&"LogManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/LogManager.gd"
		)
	)
	_ensure_manager(
		&"EventManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/EventManager.gd"
		)
	)
	_ensure_manager(
		&"NotificationManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/NotificationManager.gd"
		)
	)
	_ensure_manager(
		&"SettingsManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/SettingsManager.gd"
		)
	)
	_ensure_manager(
		&"AudioManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/AudioManager.gd"
		)
	)
	_ensure_manager(
		&"TimeManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/TimeManager.gd"
		)
	)
	_ensure_manager(
		&"ResourceManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/ResourceManager.gd"
		)
	)
	_ensure_manager(
		&"PoolManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/PoolManager.gd"
		)
	)
	_ensure_manager(
		&"SceneManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/SceneManager.gd"
		)
	)
	_ensure_manager(
		&"SaveManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/SaveManager.gd"
		)
	)
	_ensure_manager(
		&"NetworkManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/NetworkManager.gd"
		)
	)
	_ensure_manager(
		&"InputManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/InputManager.gd"
		)
	)

	# Project-owned game flow.
	_ensure_manager(&"GameManager", load("res://src/managers/ExampleGameManager.gd"))

	_ensure_manager(
		&"UIManager",
		_load_script(
			"res://addons/godot_game_framework/addons/godot_game_framework/core/managers/UIManager.gd"
		)
	)
