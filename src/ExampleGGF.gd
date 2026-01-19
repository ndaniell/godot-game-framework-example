extends "res://addons/godot_game_framework/GGF.gd"

const _MANAGERS_BASE := "res://addons/godot_game_framework/core/managers/"


func _bootstrap() -> void:
	# Copy the framework’s bootstrap ordering, but inject our project-owned GameManager.
	# This keeps the submodule pristine while letting the example own game flow.
	if _bootstrapped:
		return
	_bootstrapped = true

	_load_type_scripts()

	_ensure_manager(&"LogManager", _load_script(_MANAGERS_BASE + "LogManager.gd"))
	_ensure_manager(&"EventManager", _load_script(_MANAGERS_BASE + "EventManager.gd"))
	_ensure_manager(&"NotificationManager", _load_script(_MANAGERS_BASE + "NotificationManager.gd"))
	_ensure_manager(&"SettingsManager", _load_script(_MANAGERS_BASE + "SettingsManager.gd"))
	_ensure_manager(&"AudioManager", _load_script(_MANAGERS_BASE + "AudioManager.gd"))
	_ensure_manager(&"TimeManager", _load_script(_MANAGERS_BASE + "TimeManager.gd"))
	_ensure_manager(&"ResourceManager", _load_script(_MANAGERS_BASE + "ResourceManager.gd"))
	_ensure_manager(&"PoolManager", _load_script(_MANAGERS_BASE + "PoolManager.gd"))
	_ensure_manager(&"SceneManager", _load_script(_MANAGERS_BASE + "SceneManager.gd"))
	_ensure_manager(&"SaveManager", _load_script(_MANAGERS_BASE + "SaveManager.gd"))
	_ensure_manager(&"NetworkManager", _load_script(_MANAGERS_BASE + "NetworkManager.gd"))
	_ensure_manager(&"InputManager", _load_script(_MANAGERS_BASE + "InputManager.gd"))

	# Project-owned game flow.
	_ensure_manager(&"GameManager", load("res://src/managers/ExampleGameManager.gd"))

	_ensure_manager(&"UIManager", _load_script(_MANAGERS_BASE + "UIManager.gd"))
