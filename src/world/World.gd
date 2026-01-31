extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/Player.tscn")

var _players: Dictionary = {}  # peer_id -> CharacterBody3D


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
	# React to connection lifecycle through the framework’s managers/events.
	var ev := GGF.events()
	if ev:
		ev.subscribe_owned("peer_joined", self, "_on_peer_joined")
		ev.subscribe_owned("peer_left", self, "_on_peer_left")

	_spawn_existing_peers()


func _spawn_existing_peers() -> void:
	var net: GGF_NetworkManager = GGF.network()
	if net == null:
		return
	for peer_id in _get_peer_ids():
		_spawn_player(peer_id)


func _on_peer_joined(data: Dictionary) -> void:
	var peer_id := int(data.get("peer_id", 0))
	_spawn_player(peer_id)

	# If host is already playing, automatically start the game for the late joiner
	var net: GGF_NetworkManager = GGF.network()
	var gm: GGF_GameManager = GGF.game()
	if net and gm and net.is_host() and gm.is_in_state("PLAYING"):
		net.send_session_event_to_peer(peer_id, &"start_game", {})


func _on_peer_left(data: Dictionary) -> void:
	var peer_id := int(data.get("peer_id", 0))
	if _players.has(peer_id):
		var p := _players[peer_id] as Node
		_players.erase(peer_id)
		if is_instance_valid(p):
			p.queue_free()


func _spawn_player(peer_id: int) -> void:
	if peer_id <= 0 or _players.has(peer_id):
		return

	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player_%d" % peer_id
	add_child(player)
	player.global_position = Vector3(0, 2, 0) + Vector3(peer_id % 4, 0, float(peer_id) / 4.0)

	# Assign multiplayer authority for client-side control.
	player.set_multiplayer_authority(peer_id)

	_players[peer_id] = player


func get_closest_player(from_position: Vector3) -> Node3D:
	var closest: Node3D = null
	var closest_distance := INF

	for player in _players.values():
		if not is_instance_valid(player):
			continue
		var p := player as Node3D
		var dist := from_position.distance_to(p.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = p

	return closest
