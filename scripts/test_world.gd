extends Node

@onready var item_list_label: Label = $CanvasLayer/HUD/ItemListLabel
@onready var player: Player = $Player

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

#this code below is stupid.
