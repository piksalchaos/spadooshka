extends Node

const SERVER_BROWSER_SCENE = preload("res://scenes/server_browser.tscn")

const PLAYER_FILE_NAMES = { # godot 4.4 is actually adding typed arrays, so this can be typed later
	"bunny": "res://scenes/agents/bunny/bunny.tscn",
	"catboy": "res://scenes/agents/catboy/catboy.tscn",
	"madoka": "res://scenes/agents/madoka/madoka.tscn",
	"sandy": "res://scenes/agents/sandy/sandy.tscn"
}

const MAP_FILE_NAMES = {
	"map_1" = "res://scenes/maps/map_1.tscn",
	"map_2" = "res://scenes/maps/map_2.tscn",
	"map_3" = "res://scenes/maps/map_3.tscn"
}

@export var server_port = 8910

var enet_peer = ENetMultiplayerPeer.new()
var failed_listen_port_bind = false
var server_browser: ServerBrowser

@onready var gui: Control = $GUI

@onready var multiplayer_container: Node = $MultiplayerContainer
@onready var pre_game_menu: Control = $GUI/PreGameMenu
@onready var preliminary_screen: Control = $GUI/PreliminaryScreen
@onready var hud: HUD = $GUI/HUD

@onready var lobby_music: AudioStreamPlayer = $LobbyMusic
@onready var battle_music: AudioStreamPlayer = $BattleMusic

var map: Map

var peer_selection_choices = {}

const ROUNDS_TO_WIN: int = 5
var round_number: int = 1
var rounds_won: int = 0

const HOST_NUMBER = 1

signal score_changed(round_number: int, P1_score: int, P2_score: int)

func _ready() -> void:
	lobby_music.play()
	SpawnerManager.multiplayer_container = multiplayer_container
	score_changed.connect(hud.update_score_display.rpc)

func _on_title_screen_exit_button_pressed() -> void:
	get_tree().quit()

func _on_pre_game_menu_local_game_button_pressed() -> void:
	set_up_server_browser()

func _on_pre_game_menu_local_menu_back_button_pressed() -> void:
	close_server_browser()

func _on_pre_game_menu_host_button_pressed(room_name: String) -> void:
	enet_peer.create_server(server_port)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(pre_game_menu.on_peer_connected)
	multiplayer.peer_disconnected.connect(pre_game_menu.on_peer_disconnected)
	
	if server_browser:
		server_browser.set_up_broadcast(room_name)

func set_up_server_browser():
	server_browser = SERVER_BROWSER_SCENE.instantiate()
	server_browser.failed_listen_port_bind.connect(pre_game_menu.on_failed_listen_port_bind)
	server_browser.found_server.connect(pre_game_menu.on_found_server)
	server_browser.updated_server.connect(pre_game_menu.on_updated_server)
	server_browser.removed_server.connect(pre_game_menu.on_removed_server)
	add_child(server_browser)

func _on_pre_game_menu_join_button_pressed(ip_address: String) -> void:
	join_by_ip(ip_address)

func join_by_ip(ip_address: String):
	var error = enet_peer.create_client(ip_address, server_port)
	if error == OK:
		multiplayer.multiplayer_peer = enet_peer
		pre_game_menu.switch_local_menu_to_lobby_menu()
		multiplayer.server_disconnected.connect(pre_game_menu.on_server_disconnected)
	else:
		print('failed to join lololol')

func _on_pre_game_menu_lobby_back_button_pressed() -> void:
	if multiplayer.is_server():
		enet_peer.close()
		server_browser.clean_up_broadcaster()
	else:
		multiplayer.multiplayer_peer.disconnect_peer(1)

func _on_pre_game_menu_lobby_start_button_pressed() -> void:
	assert(multiplayer.get_unique_id() == HOST_NUMBER, \
		"wtf, only the host should be able to start the game")
	close_server_browser.rpc() 

@rpc("call_local", "reliable")
func close_server_browser():
	if server_browser and is_instance_valid(server_browser):
		server_browser.queue_free()
		print("closed server browser")

func _on_agent_map_select_menu_finished_selection(
		peer_id: int, agent_name: String, map_name: String
	) -> void:
	record_peer_selection_choice.rpc(peer_id, agent_name, map_name)

func _on_preliminary_screen_cancelled_selection(peer_id: int) -> void:
	remove_peer_selection_choice.rpc(peer_id)

@rpc("call_local", "any_peer", "reliable")
func record_peer_selection_choice(peer_id: int, agent_name: String, map_name: String):
	peer_selection_choices[peer_id] = {"agent_name": agent_name, "map_name": map_name} 
	preliminary_screen.update_with_peer_selection_choices(peer_selection_choices)

@rpc("call_local", "any_peer", "reliable")
func remove_peer_selection_choice(peer_id):
	peer_selection_choices.erase(peer_id)
	preliminary_screen.update_with_peer_selection_choices(peer_selection_choices)

func _on_preliminary_screen_begin_button_pressed() -> void:
	play_game()

func play_game():
	rounds_won = 0
	round_number = 1
	gui.prepare_for_game.rpc()
	change_to_battle_music.rpc()
	choose_map()
	add_players()
	play_round()
	peer_selection_choices = {}

@rpc("call_local", "authority", "reliable")
func change_to_battle_music():
	lobby_music.stop()
	battle_music.play()

func choose_map():
	var map_votes = []
	for peer_choice in peer_selection_choices.values():
		map_votes.append(peer_choice["map_name"])
	var chosen_map_name = "map_1" if map_votes.is_empty() else map_votes.pick_random()
	map = load(MAP_FILE_NAMES[chosen_map_name]).instantiate()
	multiplayer_container.add_child(map)

func add_players():
	add_player(1)
	for peer_id in multiplayer.get_peers():
		add_player(peer_id)

func add_player(peer_id: int):
	var scene = PLAYER_FILE_NAMES[peer_selection_choices[peer_id]["agent_name"]]
	var player = load(scene).instantiate()
	player.name = str(peer_id)
	multiplayer_container.add_child(player)
	map.players.append(player)

func remove_player(peer_id: int):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func play_round():
	get_tree().call_group("free_after_round", "queue_free")
	map.despawn_loot_boxes()
	map.spawn_loot_boxes()
	map.spawn_players()

@rpc("any_peer", "call_local", "reliable")
func end_round(dead_peer_id: int):
	if not is_multiplayer_authority(): return
	
	if dead_peer_id != HOST_NUMBER:
		rounds_won += 1
	var P1_score: int = rounds_won
	var P2_score: int = round_number - rounds_won
	
	if P1_score < ROUNDS_TO_WIN and P2_score < ROUNDS_TO_WIN:
		round_number += 1
		score_changed.emit(round_number, P1_score, P2_score)
		show_end_round_icon.rpc(dead_peer_id != HOST_NUMBER)
		await get_tree().create_timer(5).timeout
		clear_end_round_icon.rpc()
		play_round()
	else:
		stop_battle_music.rpc()
		gui.prepare_for_end_game.rpc(P1_score == ROUNDS_TO_WIN)
		for node in multiplayer_container.get_children():
			node.queue_free()

@rpc("authority", "call_local", "reliable")
func stop_battle_music():
	battle_music.stop()

@rpc("call_local", "reliable")
func show_end_round_icon(P1_won: bool):
	if is_multiplayer_authority() == P1_won:
		hud.get_node("RoundWonIcon").visible = true #YOU TOO
	else:
		hud.get_node("RoundLostIcon").visible = true #I HATE THIS
		
@rpc("call_local", "reliable")
func clear_end_round_icon():
	hud.get_node("RoundWonIcon").visible = false
	hud.get_node("RoundLostIcon").visible = false

func _on_multiplayer_container_child_entered_tree(node: Node) -> void:
	if node is Player:
		if not node.is_multiplayer_authority(): return
		node.player_icon_changed.connect(hud.update_player_icon)
		node.ammo_changed.connect(hud.update_ammo_display)
		node.dash_changed.connect(hud.update_dash_display)
		node.gun_shot.connect(hud.on_gun_shot)
		node.health_changed.connect(hud.update_health_display)
		node.death.connect(end_round.rpc)
		node.interact_cast_changed_in_range_state.connect(hud.set_e_key_visibility)
		
		var inventory = node.get_node("Inventory")
		inventory.inventory_changed.connect(hud.update_inventory_icons)
		var effect_manager = node.get_node("EffectManager")
		effect_manager.effect_applied.connect(hud.create_effect_display)
		
func _on_gui_end_screen_back_button_pressed() -> void:
	lobby_music.play()
