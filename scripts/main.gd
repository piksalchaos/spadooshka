extends Node

const CLIENT_SCENE = preload("res://scenes/client.tscn")

const PORT = 9999

var enet_peer = ENetMultiplayerPeer.new()

@onready var client_manager: Node = $ClientManager
@onready var player_manager: Node = $PlayerManager
@onready var main_menu: PanelContainer = $GUI/MainMenu
@onready var lobby_menu: Control = $GUI/LobbyMenu
@onready var hud: HUD = $GUI/HUD
@onready var map: Node3D = $Map #temporary. later, the game will be able to automatically spawn maps and reference them

var client_ready_states = {}
var is_match_ready = false

func add_client(peer_id):
	var client = CLIENT_SCENE.instantiate()
	client.name = str(peer_id)
	client_manager.add_child(client)

func remove_client(peer_id):
	var client = client_manager.get_node_or_null(str(peer_id))
	if client:
		client.queue_free()

func _on_main_menu_host_button_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.peer_connected.connect(add_client)
	multiplayer.peer_disconnected.connect(remove_client)
	
	add_client(multiplayer.get_unique_id())
	lobby_menu.show_host_display()
	#upnp_setup()

func _on_main_menu_join_button_pressed() -> void:
	#enet_peer.create_client(main_menu.get_address_entry_text(), PORT)
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	lobby_menu.show_client_display()

@rpc("any_peer", "call_local")
func update_client_ready_states(peer_id, is_peer_ready):
	client_ready_states[peer_id] = is_peer_ready
	var client_ready_count = client_ready_states.values().count(true)
	if client_ready_count != client_manager.get_child_count(): return
	
	if multiplayer.get_unique_id() == 1:
		lobby_menu.show_start_button()
	else:
		lobby_menu.show_waiting_label()

func _on_lobby_menu_ready_button_pressed(peer_id: int, is_ready: bool) -> void:
	update_client_ready_states.rpc(peer_id, is_ready)

@rpc("call_local")
func prepare_GUI_for_match():
	lobby_menu.hide()
	hud.show()

func begin_match():
	for client: Client in client_manager.get_children():
		var player = client.create_player()
		player_manager.add_child(player)
	prepare_GUI_for_match.rpc()

func _on_lobby_menu_start_button_pressed() -> void:
	for client: Client in client_manager.get_children():
		var player = client.create_player()
		player_manager.add_child(player)
	prepare_GUI_for_match.rpc()

func _on_client_manager_child_order_changed() -> void:
	if not is_instance_valid(lobby_menu): return
	lobby_menu.update_number_of_players(client_manager.get_child_count())

func _on_player_manager_child_entered_tree(player: Player) -> void:
	if not player.is_multiplayer_authority(): return
	player.ammo_changed.connect(hud.update_ammo_display)
	player.dash_changed.connect(hud.update_dash_display)
	player.health_changed.connect(hud.update_health_display)

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
