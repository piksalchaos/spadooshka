extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

#@onready var item_list_label: Label = $CanvasLayer/HUD/ItemListLabel
@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var hud: Control = $CanvasLayer/HUD

func _on_main_menu_host_button_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()

func _on_main_menu_join_button_pressed() -> void:
	enet_peer.create_client("localhost", PORT)
	#enet_peer.create_client(main_menu.get_address_entry_text(), PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	player.ammo_changed.connect(hud.update_ammo_display)
	player.dash_changed.connect(hud.update_dash_display)
	player.health_changed.connect(hud.update_health_display)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

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
