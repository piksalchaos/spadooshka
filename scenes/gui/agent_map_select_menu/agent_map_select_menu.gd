extends Control

var selected_agent_name: String
var selected_map_name: String

@onready var ready_button: TextureButton = $ReadyButton

signal finished_selection(peer_id: int, agent_name: String, map_name: String)

func _on_agent_icon_container_icon_selected(icon_name: String) -> void:
	selected_agent_name = icon_name
	check_for_ready_button()

func _on_map_icon_container_icon_selected(icon_name: String) -> void:
	selected_map_name = icon_name
	check_for_ready_button()

func check_for_ready_button():
	ready_button.disabled = not (selected_agent_name and selected_map_name)

func _on_ready_button_pressed() -> void:
	finished_selection.emit(
		multiplayer.get_unique_id(), selected_agent_name, selected_map_name
	)
