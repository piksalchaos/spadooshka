extends Node

@export var player: Player
@onready var gun: Gun = player.equipped_gun #probably a bad idea???
@onready var item_list_label = $HUD/ItemListLabel
@onready var gun_ammo_label = $HUD/GunAmmoLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	item_list_label.text = ""
	for i in player.items.size():
		if i == player.selected_item_slot:
			item_list_label.text += "speed boost <-\n" #in the time of writing this code, only speed boost items exist. bc the game is no text, these will be replaced with icons instead later
		else:
			item_list_label.text += "speed boost\n"
	
	gun_ammo_label.text = str(gun.num_bullets) + "/" + str(gun.MAG_CAPACITY)
