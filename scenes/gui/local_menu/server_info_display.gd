class_name ServerInfoDisplay extends HBoxContainer

@onready var room_name_label: Label = $RoomName
@onready var ip_label: Label = $IP
@onready var player_count_label: Label = $PlayerCount

signal join_button_pressed(ip_address: String)

func update_labels(room_name: String, ip: String, player_count: int):
	room_name_label.text = room_name
	ip_label.text = ip
	player_count_label.text = str(player_count)

func _on_join_button_pressed() -> void:
	if ip_label.text != "":
		join_button_pressed.emit(ip_label.text)
