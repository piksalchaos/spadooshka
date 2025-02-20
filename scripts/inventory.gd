extends Node

@onready var player: CharacterBody3D = $".."
@onready var camera: Camera3D = $"../Head/Camera"

const MAX_ITEM_COUNT: int = 3

var items: Array[Item] = []
var current_item_slot: int = 0

signal inventory_changed(items: Array[Item], current_item_slot: int)

func _on_player_interact(target: Object) -> void:
	if target is LootBox and items.size() < MAX_ITEM_COUNT:
		var item = target.obtain_item()
		item.player = player
		if item.need_camera:
			camera.add_child(item)
		else:
			self.add_child(item)
		items.append(item)
		
		current_item_slot = items.size() - 1
		inventory_changed.emit(items, current_item_slot)

	var fart = []
	for item in items:
		fart.append(item.item_name)
	print(fart)
	

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if items.size() == 0:
		return
	if event.is_action_pressed("use_item"):
		if items[current_item_slot].use():
			items.pop_at(current_item_slot)
			current_item_slot -= 1
			inventory_changed.emit(items, current_item_slot)
			return
	elif event.is_action_pressed("item_slot_left"):
		shift_item_slot_left()
	elif event.is_action_pressed("item_slot_right"):
		shift_item_slot_right()
	else:
		for item_slot in range(3):
			if event.is_action_pressed(str(item_slot + 1)) and items.size() >= item_slot + 1:
				current_item_slot = item_slot
				print(current_item_slot)
				inventory_changed.emit(items, current_item_slot)
				break

func shift_item_slot_left():
	current_item_slot = (current_item_slot + items.size() - 1) % items.size()
	inventory_changed.emit(items, current_item_slot)
	
func shift_item_slot_right():
	current_item_slot = (current_item_slot + 1) % items.size()
	inventory_changed.emit(items, current_item_slot)
