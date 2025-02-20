extends Control

@onready var server_state_label: Label = $ServerStateLabel
@onready var player_number_label: Label = $PlayerNumberLabel
@onready var ready_button: Button = $ReadyButton

var is_host = false

signal ready_button_pressed(peer_id: int, is_ready: bool)

func update_number_of_players(new_number):
	player_number_label.text = "Number of Players: " + str(new_number)

func show_host_display():
	show()
	server_state_label.text = "Hosting Server"
	is_host = true

func show_client_display():
	show()
	server_state_label.text = "Joined Server"

func _on_ready_button_pressed() -> void:
	ready_button_pressed.emit(multiplayer.get_unique_id(), ready_button.button_pressed)
