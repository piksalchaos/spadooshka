extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

const PORT = 9999

var enet_peer = ENetMultiplayerPeer.new()

@onready var main_menu: PanelContainer = $GUI/MainMenu
@onready var hud: HUD = $GUI/HUD
@onready var map: Node3D = $Map #temporary. later, the game will be able to automatically spawn maps and reference them

func _on_main_menu_host_button_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	hud.show()
	#upnp_setup()

func _on_main_menu_join_button_pressed() -> void:
	#enet_peer.create_client(main_menu.get_address_entry_text(), PORT)
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	hud.show()

func add_player(peer_id):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.ammo_changed.connect(hud.update_ammo_display)
		player.dash_changed.connect(hud.update_dash_display)
		player.health_changed.connect(hud.update_health_display)
		player.get_node("Inventory").inventory_changed.connect(hud.update_inventory_icons)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node.is_multiplayer_authority():
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
