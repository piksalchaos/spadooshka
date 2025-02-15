extends Node

@onready var item_list_label: Label = $CanvasLayer/HUD/ItemListLabel
@onready var player: Player = $Player

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

#this code below is stupid.
func _process(delta: float) -> void:
	item_list_label.text = ""
	for i in player.items.size():
		if i == player.selected_item_slot:
			item_list_label.text += "speed boost <-\n" #in the time of writing this code, only speed boost items exist. bc the game is no text, these will be replaced with icons instead later
		else:
			item_list_label.text += "speed boost\n"
