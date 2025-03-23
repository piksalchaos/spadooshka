extends Node

const SERVER_BROWSER_SCENE = preload("res://scenes/server_browser.tscn")
const PLAYER_SCENE = preload("res://scenes/player/bob_agent/bob.tscn") #preload("res://scenes/player/player.tscn")

const PLAYER_FILE_NAMES: Array[String] = [
	"res://scenes/player/bob_agent/bob.tscn",
	"res://scenes/player/shart_agent/shart.tscn"
]

const MAP_FILE_NAMES: Array[String] = [
	"res://scenes/maps/map_1.tscn",
	"res://scenes/maps/map_2.tscn"
]

@export var server_port = 8910

var enet_peer = ENetMultiplayerPeer.new()
var failed_listen_port_bind = false
var server_browser: ServerBrowser

@onready var title_screen: Control = $GUI/TitleScreen
@onready var main_menu: Control = $GUI/MainMenu
@onready var multiplayer_container: Node = $MultiplayerContainer
@onready var local_menu: LocalMenu = $GUI/LocalMenu
@onready var lobby_menu: LobbyMenu = $GUI/LobbyMenu
@onready var hud: HUD = $GUI/HUD

var map: Map

var peer_ready_states = {}

const ROUNDS_TO_WIN: int = 3
var round_number: int = 1
var rounds_won: int = 0

signal score_changed(round_number: int, P1_score: int, P2_score: int)

func _ready() -> void:
	score_changed.connect(hud.update_score_display.rpc)

func _on_title_screen_start_button_pressed() -> void:
	title_screen.hide()
	main_menu.show()

func _on_title_screen_exit_button_pressed() -> void:
	get_tree().quit()

func _on_main_menu_local_game_button_pressed() -> void:
	main_menu.hide()
	local_menu.show()
	set_up_server_browser()

func _on_local_menu_host_button_pressed() -> void:
	enet_peer.create_server(server_port)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(lobby_menu.on_peer_connected)
	multiplayer.peer_disconnected.connect(lobby_menu.on_peer_disconnected)
	lobby_menu.add_player_display(multiplayer.get_unique_id())
	lobby_menu.show()
	
	if server_browser:
		server_browser.set_up_broadcast("placeholder username")

func set_up_server_browser():
	server_browser = SERVER_BROWSER_SCENE.instantiate()
	server_browser.failed_listen_port_bind.connect(local_menu.show_listener_failed_label)
	server_browser.found_server.connect(local_menu.add_server_info_display)
	server_browser.updated_server.connect(local_menu.update_server_info_display)
	server_browser.removed_server.connect(local_menu.remove_server_info_display)
	add_child(server_browser)

func _on_local_menu_join_button_pressed(ip_address: String) -> void:
	join_by_ip(ip_address)

func join_by_ip(ip_address: String):
	enet_peer.create_client(ip_address, server_port)
	multiplayer.multiplayer_peer = enet_peer
	lobby_menu.show()

func _on_local_menu_singleplayer_button_pressed() -> void:
	play_game()

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

func _on_lobby_menu_start_button_pressed() -> void:
	assert(multiplayer.get_unique_id() == 1, \
		"wtf, only the host should be able to start the game")
	play_game()

func play_game():
	prepare_client_for_game.rpc()
	choose_map()
	add_players()
	play_round()

@rpc("call_local")
func prepare_client_for_game():
	if server_browser:
		server_browser.queue_free()
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
	var scene = PLAYER_FILE_NAMES.pick_random()
	print(scene)
	var player = load(scene).instantiate()
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
		node.player_icon_changed.connect(hud.update_player_icon)
		node.ammo_changed.connect(hud.update_ammo_display)
		node.dash_changed.connect(hud.update_dash_display)
		node.health_changed.connect(hud.update_health_display)
		
		var inventory = node.get_node("Inventory")
		inventory.inventory_changed.connect(hud.update_inventory_icons)
		var effect_manager = node.get_node("EffectManager")
		effect_manager.effect_applied.connect(hud.create_effect_display)
		node.death.connect(end_round.rpc)
