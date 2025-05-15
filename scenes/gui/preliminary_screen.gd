extends Control

const SANDY_IMAGE = preload("res://assets/images/agents_full_body/ada.png")
const BUNNY_IMAGE = preload("res://assets/images/agents_full_body/bunny.png")
const CATBOY_IMAGE = preload("res://assets/images/agents_full_body/catboy.png")
const MADOKA_IMAGE = preload("res://assets/images/agents_full_body/madoka.png")

@onready var self_texture_rect: TextureRect = $SelfDisplay/TextureRect
@onready var opponent_texture_rect: TextureRect = $OpponentDisplay/TextureRect
@onready var begin_button: TextureButton = $BeginButton
#@onready var waiting_label: Label = $WaitingLabel

signal back_button_pressed
signal cancelled_selection(peer_id: int)
signal begin_button_pressed

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
	cancelled_selection.emit(multiplayer.get_unique_id())

# this code is disgusting and horrid
func update_with_peer_selection_choices(peer_selection_choices: Dictionary):
	#all temporary code. text will be replaced with actual images later
	#when i have the time, i could maybe replace code with lobby menu system
	var every_peer = multiplayer.get_peers()
	every_peer.append(multiplayer.get_unique_id())
	
	var get_peer_agent_name = func(peer: int) -> String:
		return peer_selection_choices[peer]["agent_name"]
	
	for peer in every_peer:
		var agent_name = get_peer_agent_name.call(peer) if peer_selection_choices.has(peer) else ""
		if peer == multiplayer.get_unique_id():
			self_texture_rect.texture = get_texture_from_agent_name(agent_name)
		else:
			opponent_texture_rect.texture = get_texture_from_agent_name(agent_name)
	
	if every_peer.size() == peer_selection_choices.size():
		if multiplayer.get_unique_id() == 1:
			begin_button.show()
		else:
			pass#waiting_label.show()
	else:
		begin_button.hide()
		#waiting_label.hide()

func get_texture_from_agent_name(agent_name: String):
	match agent_name:
		"bunny":
			return BUNNY_IMAGE
		"catboy":
			return CATBOY_IMAGE
		"madoka":
			return MADOKA_IMAGE
		"sandy":
			return SANDY_IMAGE
		_:
			return null

func _on_begin_button_pressed() -> void:
	begin_button_pressed.emit()
