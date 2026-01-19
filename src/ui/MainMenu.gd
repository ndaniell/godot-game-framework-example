extends Control

@onready var _host_button: Button = %HostButton
@onready var _join_button: Button = %JoinButton
@onready var _quit_button: Button = %QuitButton
@onready var _ip_edit: LineEdit = %IpEdit
@onready var _port_edit: LineEdit = %PortEdit


func _ready() -> void:
	_host_button.pressed.connect(_on_host_pressed)
	_join_button.pressed.connect(_on_join_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_host_pressed() -> void:
	var net := GGF.get_manager(&"NetworkManager")
	if net == null:
		GGF.notifications().show_error("NetworkManager not available")
		return

	if bool(net.host(_parse_port())):
		GGF.get_manager(&"GameManager").change_state("LOBBY")


func _on_join_pressed() -> void:
	var net := GGF.get_manager(&"NetworkManager")
	if net == null:
		GGF.notifications().show_error("NetworkManager not available")
		return

	var ip := _ip_edit.text.strip_edges()
	if ip.is_empty():
		GGF.notifications().show_error("Enter a server IP")
		return

	if bool(net.join(ip, _parse_port())):
		GGF.get_manager(&"GameManager").change_state("LOBBY")


func _on_quit_pressed() -> void:
	var gm := GGF.get_manager(&"GameManager")
	if gm and gm.has_method("quit_game"):
		gm.quit_game()
	else:
		get_tree().quit()


func _parse_port() -> int:
	var p := int(_port_edit.text)
	return p if p > 0 else 8910
