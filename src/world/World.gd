extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/Player.tscn")

var _players: Dictionary = {}  # peer_id -> CharacterBody3D


func _ready() -> void:
	# React to connection lifecycle through the framework’s managers/events.
	GGF.events().subscribe("peer_joined", _on_peer_joined)
	GGF.events().subscribe("peer_left", _on_peer_left)

	_spawn_existing_peers()


func _exit_tree() -> void:
	var ev := GGF.events()
	if ev:
		ev.unsubscribe("peer_joined", _on_peer_joined)
		ev.unsubscribe("peer_left", _on_peer_left)


func _spawn_existing_peers() -> void:
	var net := GGF.get_manager(&"NetworkManager")
	if net == null:
		return
	for peer_id in net.get_peer_ids():
		_spawn_player(int(peer_id))
	# Ensure local player exists even if get_peer_ids omits it early.
	_spawn_player(multiplayer.get_unique_id())


func _on_peer_joined(data: Dictionary) -> void:
	_spawn_player(int(data.get("peer_id", 0)))


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
