extends Control

@onready var _status: Label = %StatusLabel
@onready var _peers: Label = %PeersLabel
@onready var _start: Button = %StartGameButton
@onready var _back: Button = %BackButton


func _get_peer_ids() -> Array[int]:
	var ids: Array[int] = []
	if multiplayer.multiplayer_peer == null:
		return ids
	ids.append(multiplayer.get_unique_id())
	for p in multiplayer.get_peers():
		ids.append(int(p))
	ids.sort()
	return ids


func _ready() -> void:
	_start.pressed.connect(_on_start_pressed)
	_back.pressed.connect(_on_back_pressed)

	# Subscribe to framework-mirrored network lifecycle events.
	GGF.events().subscribe("network_connected", _on_network_connected)
	GGF.events().subscribe("network_disconnected", _on_network_disconnected)
	GGF.events().subscribe("peer_joined", _on_peer_changed)
	GGF.events().subscribe("peer_left", _on_peer_changed)

	# Also listen for the project session event used to start the game.
	GGF.events().subscribe("start_game", _on_start_game_event)

	_refresh()


func _exit_tree() -> void:
	# Best-effort cleanup; safe if EventManager already gone.
	var ev := GGF.events()
	if ev:
		ev.unsubscribe("network_connected", _on_network_connected)
		ev.unsubscribe("network_disconnected", _on_network_disconnected)
		ev.unsubscribe("peer_joined", _on_peer_changed)
		ev.unsubscribe("peer_left", _on_peer_changed)
		ev.unsubscribe("start_game", _on_start_game_event)


func _refresh() -> void:
	var net := GGF.get_manager(&"NetworkManager")
	if net == null:
		_status.text = "Status: offline"
		_peers.text = "Peers: []"
		_start.disabled = true
		return

	var connected: bool = bool(net.is_network_connected())
	var is_host: bool = bool(net.is_host())
	var mode := "host" if is_host else "client"
	_status.text = "Status: " + ("online (" + mode + ")" if connected else "offline")
	_peers.text = "Peers: " + str(_get_peer_ids())
	_start.disabled = not (connected and is_host)


func _on_start_pressed() -> void:
	var net := GGF.get_manager(&"NetworkManager")
	if net == null or not bool(net.is_host()):
		return

	# Server broadcasts; NetworkManager accepts it locally and RPCs to clients.
	net.broadcast_session_event(&"start_game", {})
	GGF.get_manager(&"GameManager").change_state("PLAYING")


func _on_back_pressed() -> void:
	var net := GGF.get_manager(&"NetworkManager")
	if net and net.has_method("disconnect_from_game"):
		net.disconnect_from_game()
	GGF.get_manager(&"GameManager").change_state("MENU")


func _on_network_connected(_data: Dictionary) -> void:
	_refresh()


func _on_network_disconnected(_data: Dictionary) -> void:
	_refresh()


func _on_peer_changed(_data: Dictionary) -> void:
	_refresh()


func _on_start_game_event(_data: Dictionary) -> void:
	# Client receives this via EventManager mirroring the session event.
	GGF.get_manager(&"GameManager").change_state("PLAYING")
