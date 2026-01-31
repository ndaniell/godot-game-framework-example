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

	# Subscribe to framework-mirrored network lifecycle events with auto-cleanup.
	var ev := GGF.events()
	if ev:
		ev.subscribe_owned("network_connected", self, "_on_network_connected")
		ev.subscribe_owned("network_disconnected", self, "_on_network_disconnected")
		ev.subscribe_owned("peer_joined", self, "_on_peer_changed")
		ev.subscribe_owned("peer_left", self, "_on_peer_changed")
		ev.subscribe_owned("start_game", self, "_on_start_game_event")

	_refresh()


func _refresh() -> void:
	var net: GGF_NetworkManager = GGF.network()
	if net == null:
		_status.text = "Status: offline"
		_peers.text = "Peers: []"
		_start.disabled = true
		return

	var connected: bool = net.is_network_connected()
	var is_host: bool = net.is_host()
	var mode := "host" if is_host else "client"
	_status.text = "Status: " + ("online (" + mode + ")" if connected else "offline")
	_peers.text = "Peers: " + str(_get_peer_ids())
	_start.disabled = not (connected and is_host)


func _on_start_pressed() -> void:
	var net: GGF_NetworkManager = GGF.network()
	if net == null or not net.is_host():
		return

	# Server broadcasts; NetworkManager accepts it locally and RPCs to clients.
	net.broadcast_session_event(&"start_game", {})
	var sm: GGF_StateManager = GGF.state()
	if sm:
		sm.change_state("PLAYING")


func _on_back_pressed() -> void:
	var net: GGF_NetworkManager = GGF.network()
	if net:
		net.disconnect_from_game()
	var sm: GGF_StateManager = GGF.state()
	if sm:
		sm.change_state("MENU")


func _on_network_connected(_data: Dictionary) -> void:
	_refresh()


func _on_network_disconnected(_data: Dictionary) -> void:
	_refresh()


func _on_peer_changed(_data: Dictionary) -> void:
	_refresh()


func _on_start_game_event(_data: Dictionary) -> void:
	# Client receives this via EventManager mirroring the session event.
	var sm: GGF_StateManager = GGF.state()
	if sm:
		sm.change_state("PLAYING")
