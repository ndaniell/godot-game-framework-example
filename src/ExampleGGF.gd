extends "res://addons/godot_game_framework/GGF.gd"


func _bootstrap() -> void:
	# Delegate all manager creation to the framework.
	super._bootstrap()

	# Example-specific behavior while reusing the framework's default state machine config.
	var gm := get_manager(&"GameManager")
	if gm != null:
		(
			gm
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
						},
					},
					"PLAYING":
					{
						"change_scene": "res://scenes/World.tscn",
						"ui":
						{
							"close_all_menus": true,
							"close_all_dialogs": true,
						},
					},
				}
			)
		)
