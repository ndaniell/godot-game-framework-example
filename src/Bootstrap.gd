extends Node


func _ready() -> void:
	# Framework managers are bootstrapped by the `GGF` autoload.
	# This scene registers UI scenes with `UIManager` and drives the initial MENU state.
	if Engine.is_editor_hint():
		return

	var ui := GGF.get_manager(&"UIManager")
	if ui == null:
		push_error("Bootstrap: UIManager not available")
		return

	var main_menu_scene := load("res://ui/MainMenu.tscn") as PackedScene
	var lobby_menu_scene := load("res://ui/LobbyMenu.tscn") as PackedScene
	if main_menu_scene == null or lobby_menu_scene == null:
		push_error("Bootstrap: Failed to load UI scenes")
		return

	var main_menu := main_menu_scene.instantiate() as Control
	var lobby_menu := lobby_menu_scene.instantiate() as Control

	ui.register_ui_element("main_menu", main_menu, ui.menu_layer)
	ui.register_ui_element("lobby_menu", lobby_menu, ui.menu_layer)

	# Start in MENU; GameManager handles opening the correct menu via state callbacks.
	var gm := GGF.get_manager(&"GameManager")
	if gm and gm.has_method("change_state"):
		gm.change_state("MENU")
