extends Control

@onready var _port_edit: LineEdit = %PortEdit
@onready var _host_button: Button = %HostButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_host_button.pressed.connect(_on_host_pressed)
	_back_button.pressed.connect(_on_back_pressed)


func _on_host_pressed() -> void:
	var net: GGF_NetworkManager = GGF.network()
	if net == null:
		GGF.notifications().show_error("NetworkManager not available")
		return

	if net.host(_parse_port()):
		var sm: GGF_StateManager = GGF.state()
		if sm:
			sm.change_state("PLAYING")


func _on_back_pressed() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_menu("main_menu", true)


func _parse_port() -> int:
	var p := int(_port_edit.text)
	return p if p > 0 else 8910
