class_name LobbyMenu extends Control

const PLAYER_DISPLAY_SCENE = preload("res://scenes/gui/lobby_menu/lobby_player_display.tscn")

@onready var player_displays: VBoxContainer = $PlayerDisplays
@onready var ready_button: TextureButton = $ReadyButton
@onready var start_button: TextureButton = $StartButton

var is_host = false

signal back_button_pressed
signal ready_button_pressed(peer_id: int, is_ready: bool)
signal start_button_pressed()

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

@rpc("authority", "call_remote", "reliable")
func update_peer_player_displays():
	#lobby_menu.update_player_displays()
	for peer_id in multiplayer.get_peers():
		add_player_display(peer_id)

@rpc("call_local", "reliable")
func add_player_display(peer_id: int):
	var player_display = PLAYER_DISPLAY_SCENE.instantiate()
	player_display.name = str(peer_id)
	player_displays.add_child(player_display)

@rpc("call_local", "reliable")
func remove_player_display(peer_id: int):
	var player_display = player_displays.get_node_or_null(str(peer_id))
	if player_display:
		player_display.queue_free()

func reset():
	for player_display in player_displays.get_children():
		player_display.queue_free()
	undo_ready_button_pressed()

@rpc("call_local", "authority", "reliable")
func undo_ready_button_pressed():
	ready_button.button_pressed = false

func on_peer_connected(peer_id: int):
	update_peer_player_displays.rpc_id(peer_id)
	add_player_display.rpc(peer_id)

func on_peer_disconnected(peer_id: int):
	remove_player_display.rpc(peer_id)

@rpc("any_peer", "call_local", "reliable")
func set_player_is_ready(peer_id: int, is_ready: bool):
	var player_display = player_displays.get_node_or_null(str(peer_id))
	if player_display:
		player_display.set_is_ready(is_ready)

func _on_ready_button_pressed() -> void:
	var peer_id = multiplayer.get_unique_id()
	var is_ready = ready_button.button_pressed
	ready_button_pressed.emit(peer_id, is_ready)
	#set_player_is_ready.rpc(peer_id, is_ready)

func set_waiting_label_visibility(is_label_visible: bool):
	pass #waiting_label.visible = is_label_visible

func set_start_button_visibility(is_button_visible: bool):
	start_button.visible = is_button_visible

func _on_start_button_pressed() -> void:
	start_button_pressed.emit()
