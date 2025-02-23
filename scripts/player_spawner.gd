extends MultiplayerSpawner

var player_scene: PackedScene = preload("res://scenes/player.tscn")

func add_players():
	add_player(1)
	for peer_id in multiplayer.get_peers():
		add_player(peer_id)

func add_player(peer_id: int):
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
	

func spawn_players(spawn_positions: Array[Node]):
	var indices: Array = range(spawn_positions.size())
	indices.shuffle()
	
	for player in get_children():
		var spawn_position: Vector3 = spawn_positions[indices.pop_back()].position
		player.spawn.rpc(spawn_position)
