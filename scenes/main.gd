extends Node

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")

const MAP_FILE_NAMES: Array[String] = [
	"res://scenes/maps/map_1.tscn",
	"res://scenes/maps/map_2.tscn"
]

const PORT = 9999

var enet_peer = ENetMultiplayerPeer.new()

@onready var multiplayer_container: Node = $MultiplayerContainer
@onready var main_menu: PanelContainer = $GUI/MainMenu
@onready var lobby_menu: Control = $GUI/LobbyMenu
@onready var hud: HUD = $GUI/HUD

var map: Map

var peer_ready_states = {}

const ROUNDS_TO_WIN: int = 3
var round_number: int = 1
var rounds_won: int = 0

signal score_changed(round_number: int, P1_score: int, P2_score: int)

func _ready() -> void:
	score_changed.connect(hud.update_score_display.rpc)

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

func _on_main_menu_singleplayer_button_pressed() -> void:
	play_game()

func _on_lobby_menu_start_button_pressed() -> void:
	assert(multiplayer.get_unique_id() == 1, \
		"wtf, only the host should be able to start the game")
	play_game()

@rpc("call_local")
func update_number_of_players():
	if not is_instance_valid(lobby_menu): return
	lobby_menu.update_number_of_players(multiplayer.get_peers().size() + 1)

func _on_peer_connected(peer_id):
	update_number_of_players.rpc()
	update_peer_ready_states(peer_id, false)
func _on_peer_disconnected(peer_id):
	update_number_of_players.rpc()

func _on_lobby_menu_ready_button_pressed(peer_id: int, is_ready: bool) -> void:
	update_peer_ready_states.rpc(peer_id, is_ready)

@rpc("any_peer", "call_local")
func update_peer_ready_states(peer_id, is_peer_ready):
	peer_ready_states[peer_id] = is_peer_ready
	var peer_ready_count = peer_ready_states.values().count(true)
	var are_peers_ready = peer_ready_count == multiplayer.get_peers().size()+1
	if multiplayer.get_unique_id() == 1:
		lobby_menu.set_start_button_visibility(are_peers_ready)
	else:
		lobby_menu.set_waiting_label_visibility(are_peers_ready)

func play_game():
	prepare_GUI_for_game.rpc()
	choose_map()
	add_players()
	play_round()

@rpc("call_local")
func prepare_GUI_for_game():
	lobby_menu.hide()
	hud.show()

func choose_map():
	map = load(MAP_FILE_NAMES.pick_random()).instantiate()
	multiplayer_container.add_child(map)

func add_players():
	add_player(1)
	for peer_id in multiplayer.get_peers():
		add_player(peer_id)

func add_player(peer_id: int):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	multiplayer_container.add_child(player)
	map.players.append(player)

func remove_player(peer_id: int):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func play_round():
	map.despawn_loot_boxes()
	map.spawn_loot_boxes()
	map.spawn_players()

@rpc("any_peer", "call_local")
func end_round(dead_peer_id: int):
	if not is_multiplayer_authority(): return
	
	if dead_peer_id != 1:
		rounds_won += 1
	var P1_score: int = rounds_won
	var P2_score: int = round_number - rounds_won
	
	if P1_score < ROUNDS_TO_WIN and P2_score < ROUNDS_TO_WIN:
		round_number += 1
		score_changed.emit(round_number, P1_score, P2_score)
		play_round()
	else:
		prepare_GUI_for_end_game.rpc(P1_score == ROUNDS_TO_WIN)

@rpc("call_local")
func prepare_GUI_for_end_game(P1_won: bool):
	hud.hide()
	if is_multiplayer_authority() == P1_won:
		$GUI/VictoryScreen.show()
	else:
		$GUI/DefeatScreen.show()

func _on_multiplayer_container_child_entered_tree(node: Node) -> void:
	if node is Player:
		if not node.is_multiplayer_authority(): return
		node.ammo_changed.connect(hud.update_ammo_display)
		node.dash_changed.connect(hud.update_dash_display)
		node.health_changed.connect(hud.update_health_display)
		
		var inventory = node.get_node("Inventory")
		inventory.inventory_changed.connect(hud.update_inventory_icons)
		var effect_manager = node.get_node("EffectManager")
		effect_manager.effect_applied.connect(hud.create_effect_display)
		node.death.connect(end_round.rpc)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
