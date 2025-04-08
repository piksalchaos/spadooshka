extends Control

@onready var self_choice_label: Label = $SelfDisplay/ChoiceLabel
@onready var opponent_choice_label: Label = $OpponentDisplay/ChoiceLabel
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
		if peer == multiplayer.get_unique_id():
			self_choice_label.text = get_peer_agent_name.call(peer) \
				if peer_selection_choices.has(peer) else ""
		else:
			opponent_choice_label.text = get_peer_agent_name.call(peer) \
				if peer_selection_choices.has(peer) else ""
	
	if every_peer.size() == peer_selection_choices.size():
		if multiplayer.get_unique_id() == 1:
			begin_button.show()
		else:
			pass#waiting_label.show()
	else:
		begin_button.hide()
		#waiting_label.hide()

func _on_begin_button_pressed() -> void:
	begin_button_pressed.emit()
