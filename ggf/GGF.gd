extends "res://addons/godot_game_framework/GGF.gd"

## Project bootstrapper for Godot Game Framework (GGF).
##
## This file matches the framework's recommended integration approach:
## - Put your bootstrapper at `res://ggf/GGF.gd`
## - Have the plugin register an autoload named `GGF` pointing at it
##
## You can safely customize it (override methods, add project-specific behavior, etc.).


func _bootstrap() -> void:
	# Delegate all manager creation to the framework.
	super._bootstrap()

	# Example-specific behavior while reusing the framework's default state machine config.
	var sm := get_manager(&"StateManager")
	if sm != null:
		(
			sm
			. set(
				"state_property_overrides",
				{
					"MENU":
					{
						# Ensure the 3D world isn't still visible behind menus.
						"change_scene": "res://scenes/Bootstrap.tscn",
						"ui":
						{
							"open_menu": "main_menu",
							"open_menu_close_others": true,
							"close_all_dialogs": true,
							"hide_ui_element": "hud",
						},
					},
					# Reuse the framework's LOADING state as a simple "lobby" state for this example.
					"LOADING":
					{
						"ui":
						{
							"open_menu": "lobby_menu",
							"open_menu_close_others": true,
							"close_all_dialogs": true,
							"hide_ui_element": "hud",
						},
					},
					"PLAYING":
					{
						"change_scene": "res://scenes/World.tscn",
						"ui":
						{
							"close_all_menus": true,
							"close_all_dialogs": true,
							"show_ui_element": "hud",
						},
					},
				}
			)
		)

