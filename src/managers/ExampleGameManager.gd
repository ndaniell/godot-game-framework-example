extends GGF_GameManager


func _ready() -> void:
	# Use a project-owned state machine config (keeps example independent of framework tests/data).
	states_config_path = "res://resources/game_states.tres"
	super._ready()


func _on_menu_entered() -> void:
	var ui := GGF.get_manager(&"UIManager")
	if ui and ui.has_method("open_menu"):
		ui.open_menu("main_menu", true)


func _on_lobby_entered() -> void:
	var ui := GGF.get_manager(&"UIManager")
	if ui and ui.has_method("open_menu"):
		ui.open_menu("lobby_menu", true)


func _on_playing_entered() -> void:
	# Close menus and enter the 3D world.
	var ui := GGF.get_manager(&"UIManager")
	if ui and ui.has_method("close_all_menus"):
		ui.close_all_menus()
	change_scene("res://scenes/World.tscn")

