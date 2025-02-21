extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

const MAP_FILE_NAMES: Array[String] = [
	"res://scenes/map-scenes/map_1.tscn"
]

const PORT = 9999

var enet_peer = ENetMultiplayerPeer.new()

@onready var multiplayer_container: Node = $MultiplayerContainer
@onready var main_menu: PanelContainer = $GUI/MainMenu
@onready var lobby_menu: Control = $GUI/LobbyMenu
@onready var hud: HUD = $GUI/HUD
@onready var loot_box_spawner: LootBoxSpawner = $LootBoxSpawner

var player_spawn_positions: Array[Node]

var peer_ready_states = {}
var is_match_ready = false

@rpc("call_local")
func update_number_of_players():
	if not is_instance_valid(lobby_menu): return
	lobby_menu.update_number_of_players(multiplayer.get_peers().size() + 1)

func _on_peer_connected(peer_id):
	update_number_of_players.rpc()
func _on_peer_disconnected(peer_id):
	update_number_of_players.rpc()

func _on_main_menu_host_button_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	update_number_of_players()
	lobby_menu.show_host_display()
	#upnp_setup()

func _on_main_menu_join_button_pressed() -> void:
	#enet_peer.create_client(main_menu.get_address_entry_text(), PORT)
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	lobby_menu.show_client_display()

@rpc("any_peer", "call_local")
func update_peer_ready_states(peer_id, is_peer_ready):
	peer_ready_states[peer_id] = is_peer_ready
	var peer_ready_count = peer_ready_states.values().count(true)
	var are_peers_ready = peer_ready_count == multiplayer.get_peers().size()+1
	if multiplayer.get_unique_id() == 1:
		lobby_menu.set_start_button_visibility(are_peers_ready)
	else:
		lobby_menu.set_waiting_label_visibility(are_peers_ready)

func _on_lobby_menu_ready_button_pressed(peer_id: int, is_ready: bool) -> void:
	update_peer_ready_states.rpc(peer_id, is_ready)

@rpc("call_local")
func prepare_GUI_for_match():
	lobby_menu.hide()
	hud.show()

func add_player(peer_id: int):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	multiplayer_container.add_child(player)
	
	var random_index: int = randi_range(0, player_spawn_positions.size() - 1)
	player.spawn.rpc(player_spawn_positions[random_index].position)
	player_spawn_positions.remove_at(random_index)
	
	print("Player %s spawned at %s!" % [player.name, player.position])

func remove_player(peer_id: int):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_lobby_menu_start_button_pressed() -> void:
	assert(multiplayer.get_unique_id() == 1, \
		"wtf, only the host should be able to start the game")
	
	var map: Map = load(MAP_FILE_NAMES.pick_random()).instantiate()
	multiplayer_container.add_child(map)
	loot_box_spawner.spawn(map.loot_box_spawn_positions)
	player_spawn_positions = map.player_spawn_positions
	
	add_player(1)
	for peer_id in multiplayer.get_peers():
		add_player(peer_id)
	prepare_GUI_for_match.rpc()

func _on_multiplayer_container_child_entered_tree(node: Node) -> void:
	if node is Player:
		if not node.is_multiplayer_authority(): return
		node.ammo_changed.connect(hud.update_ammo_display)
		node.dash_changed.connect(hud.update_dash_display)
		node.health_changed.connect(hud.update_health_display)
		node.get_node("Inventory").inventory_changed.connect(hud.update_inventory_icons)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error $s" % map_result)
	
	print("Success! Join Address: $s" % upnp.query_external_address())
