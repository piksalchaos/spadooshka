extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

@onready var item_list_label: Label = $CanvasLayer/HUD/ItemListLabel
@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu

#this code below is stupid.
#better to save items not on the player node, but to something else parenting it!
#func _process(delta: float) -> void:
	#item_list_label.text = ""
	#for i in player.items.size():
		#if i == player.selected_item_slot:
			#item_list_label.text += "speed boost <-\n" #in the time of writing this code, only speed boost items exist. bc the game is no text, these will be replaced with icons instead later
		#else:
			#item_list_label.text += "speed boost\n"

func _on_main_menu_host_button_pressed() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func _on_main_menu_join_button_pressed() -> void:
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
