class_name HUD extends Node

@onready var ammo_amount_bar: ProgressBar = $AmmoAmountBar
@onready var health_bar: ProgressBar = $PlayerStatus/AspectRatioContainer/BarVBoxContainer/HealthBar
@onready var dash_bar: ProgressBar = $PlayerStatus/AspectRatioContainer/BarVBoxContainer/DashBar
@onready var inventory_slots: Array[Node] = $Inventory.get_children()

func update_ammo_display(num_bullets, mag_capacity):
	ammo_amount_bar.value = float(num_bullets) / mag_capacity

func update_dash_display(dash_value, max_dash):
	dash_bar.value = dash_value / max_dash

func update_health_display(health, max_health):
	health_bar.value = float(health) / max_health

func update_inventory_icons(items: Array[Item], current_item_slot: int):
	for i in range(inventory_slots.size()):
		var slot_icon: TextureRect = inventory_slots[i].icon
		slot_icon.texture = items[i].hud_icon if i < items.size() else null
		slot_icon.modulate = Color.AQUAMARINE if i == current_item_slot else Color.WHITE
