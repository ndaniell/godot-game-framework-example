extends Control

@onready var _host_button: Button = %HostButton
@onready var _join_button: Button = %JoinButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_host_button.pressed.connect(_on_host_pressed)
	_join_button.pressed.connect(_on_join_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_host_pressed() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_menu("host_game_menu", true)


func _on_join_pressed() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_menu("join_game_menu", true)


func _on_quit_pressed() -> void:
	var sm: GGF_StateManager = GGF.state()
	if sm:
		sm.quit_game()
	else:
		get_tree().quit()


func _on_settings_pressed() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_dialog("settings_dialog", true)
