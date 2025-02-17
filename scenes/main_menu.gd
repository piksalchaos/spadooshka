extends PanelContainer

@onready var address_entry: LineEdit = $MarginContainer/VBoxContainer/AddressEntry

signal host_button_pressed
signal join_button_pressed
#
#const PLAYER_SCENE = preload("res://scenes/player.tscn")
#const PORT = 9999
#var enet_peer = ENetMultiplayerPeer.new()
#
func _on_host_button_pressed() -> void:
	hide()
	host_button_pressed.emit()
	#enet_peer.create_server(PORT)
	#multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(add_player)
	#add_player(multiplayer.get_unique_id())

func _on_join_button_pressed() -> void:
	hide()
	join_button_pressed.emit()
	#enet_peer.create_client("localhost", PORT)
	#multiplayer.multiplayer_peer = enet_peer
#
#func add_player(peer_id):
	#var player = PLAYER_SCENE.instantiate()
	#player.name = str(peer_id)
	#add_child(player)
