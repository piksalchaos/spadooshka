extends Control

var selected_agent_name: String
var selected_map_name: String

@onready var ready_button: TextureButton = $ReadyButton

func _on_agent_icon_container_icon_selected(icon_name: String) -> void:
	selected_agent_name = icon_name
	print(icon_name)
	check_for_ready_button()

func _on_map_icon_container_icon_selected(icon_name: String) -> void:
	selected_map_name = icon_name
	check_for_ready_button()

func check_for_ready_button():
	ready_button.disabled = not (selected_agent_name and selected_map_name)
