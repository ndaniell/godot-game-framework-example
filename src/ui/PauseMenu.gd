extends Control

@onready var _resume_button: Button = %ResumeButton
@onready var _settings_button: Button = %SettingsButton
@onready var _exit_to_menu_button: Button = %ExitToMenuButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	set_process_unhandled_input(true)

	_resume_button.pressed.connect(_on_resume_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_exit_to_menu_button.pressed.connect(_on_exit_to_menu_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	visibility_changed.connect(_on_visibility_changed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Support both the InputMap action and a direct Escape fallback.
	if event.is_action_pressed("ui_cancel") or _is_escape_pressed(event):
		# Close the topmost dialog first (e.g. Settings), then the pause menu.
		var ui: GGF_UIManager = GGF.ui()
		if ui != null:
			var open_dialogs := ui.get_open_dialogs()
			if not open_dialogs.is_empty():
				var topmost_dialog: String = open_dialogs[open_dialogs.size() - 1]
				ui.close_dialog(topmost_dialog)
				get_viewport().set_input_as_handled()
				return

		_close_pause_menu()
		get_viewport().set_input_as_handled()


func _on_visibility_changed() -> void:
	if visible and is_instance_valid(_resume_button):
		_resume_button.grab_focus()


func _on_resume_pressed() -> void:
	_close_pause_menu()


func _on_settings_pressed() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_dialog("settings_dialog", true)


func _on_exit_to_menu_pressed() -> void:
	# Keep mouse visible for menu navigation.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_close_pause_menu(false)

	var net: GGF_NetworkManager = GGF.network()
	if net:
		net.disconnect_from_game()

	var sm: GGF_StateManager = GGF.state()
	if sm:
		sm.change_state("MENU")


func _on_quit_pressed() -> void:
	var sm: GGF_StateManager = GGF.state()
	if sm:
		sm.quit_game()
	else:
		get_tree().quit()


func _close_pause_menu(recapture_mouse: bool = true) -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.close_menu("pause_menu")

	if recapture_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _is_escape_pressed(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	var key_event := event as InputEventKey
	return key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE
