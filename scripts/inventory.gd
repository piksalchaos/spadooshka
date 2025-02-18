extends Node

signal use_item(item: Item)

const MAX_ITEM_COUNT: int = 3

var items: Array[Item] = []
var current_item_slot: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if items.size() > 0:
		if event.is_action_pressed("use_item"):
			use_item.emit(items[current_item_slot])
			items.pop_at(current_item_slot)
		if event.is_action_pressed("item_slot_left"):
			current_item_slot = (current_item_slot + items.size() - 1) % items.size()
		if event.is_action_pressed("item_slot_right"):
			current_item_slot = (current_item_slot + 1) % items.size()
			
func _on_player_interact(target: Object) -> void:
	if target is LootBox and items.size() < MAX_ITEM_COUNT:
		items.append(target.obtain_item())
