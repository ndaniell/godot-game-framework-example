extends Control

@onready var _ip_edit: LineEdit = %IpEdit
@onready var _port_edit: LineEdit = %PortEdit
@onready var _join_button: Button = %JoinButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_join_button.pressed.connect(_on_join_pressed)
	_back_button.pressed.connect(_on_back_pressed)


func _on_join_pressed() -> void:
	var net: GGF_NetworkManager = GGF.network()
	if net == null:
		GGF.notifications().show_error("NetworkManager not available")
		return

	var ip := _ip_edit.text.strip_edges()
	if ip.is_empty():
		GGF.notifications().show_error("Enter a server IP")
		return

	if net.join(ip, _parse_port()):
		var sm: GGF_StateManager = GGF.state()
		if sm:
			sm.change_state("LOADING")


func _on_back_pressed() -> void:
	var ui: GGF_UIManager = GGF.ui()
	if ui:
		ui.open_menu("main_menu", true)


func _parse_port() -> int:
	var p := int(_port_edit.text)
	return p if p > 0 else 8910
