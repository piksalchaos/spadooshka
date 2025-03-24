extends Control

@onready var agent_icon_container = $RotationContainer/PanelContainer/MarginContainer/AgentIconContainer

func _ready() -> void:
	for agent_icon in agent_icon_container.get_children():
		agent_icon.selected.connect(_on_agent_select_icon_selected)

func _on_agent_select_icon_selected(agent_name: String):
	print(agent_name)
	for agent_icon in agent_icon_container.get_children():
		if agent_icon.name == agent_name:
			continue
		agent_icon.button_pressed = false
