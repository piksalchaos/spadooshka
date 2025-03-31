class_name Inventory extends Node

@onready var player: CharacterBody3D = $".."
@onready var camera: Camera3D = $"../Head/Camera"

const MAX_ITEM_COUNT: int = 3

var items: Array[Item] = []
var current_item_slot: int

signal inventory_changed(items: Array[Item], current_item_slot: int)

func _on_interact_cast_interacted(target: PhysicsBody3D) -> void:
	if target is LootBox and items.size() < MAX_ITEM_COUNT:
		var item = target.obtain_item()
		item.player = player
		add_child(item)
		
		items.append(item)
		
		select_item_slot(items.size() - 1)
	
	var fart = []
	for item in items:
		fart.append(item.is_selected)
	print(fart)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if items.size() == 0: return
	
	for item_slot in range(items.size()):
		if event.is_action_pressed(str(item_slot + 1)):
			select_item_slot(item_slot)
			return
	
	if event.is_action_pressed("use_item"):
		if items[current_item_slot].use():
			items.pop_at(current_item_slot)
			select_item_slot(current_item_slot)
	elif event.is_action_pressed("item_slot_left"):
		select_item_slot(current_item_slot + 1)
	elif event.is_action_pressed("item_slot_right"):
		select_item_slot(current_item_slot - 1)
	else: return

func select_item_slot(selected_item_slot):
	current_item_slot = clamp(selected_item_slot, 0, items.size() - 1)
	inventory_changed.emit(items, current_item_slot)
	
	for i in range(items.size()):
		items[i].is_selected = i == current_item_slot

func spawn():
	current_item_slot = 0
	
	for item in items:
		item.queue_free()
	items = []
	
	inventory_changed.emit(items, current_item_slot)
