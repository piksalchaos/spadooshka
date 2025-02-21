class_name HUD extends Node

const EFFECT_DISPLAY_SCENE = preload('res://scenes/effect_display.tscn')
@onready var effects_display: HBoxContainer = $EffectsDisplay
@onready var ammo_amount_bar: ProgressBar = $AmmoAmountBar
@onready var health_bar: ProgressBar = $PlayerStatus/MarginAdjuster/BarVBoxContainer/HealthBar
@onready var dash_bar: ProgressBar = $PlayerStatus/MarginAdjuster/BarVBoxContainer/DashBar
@onready var inventory_slots: Array[Node] = $Inventory.get_children()

func update_ammo_display(num_bullets, mag_capacity):
	ammo_amount_bar.value = float(num_bullets) / mag_capacity

func update_dash_display(dash_value, max_dash):
	dash_bar.value = dash_value / max_dash

func update_health_display(health, max_health):
	health_bar.value = float(health) / max_health

func create_effect_display(effect: Effect):
	var effect_display = EFFECT_DISPLAY_SCENE.instantiate()
	effect_display.effect = effect
	effects_display.add_child(effect_display)

func update_inventory_icons(items: Array[Item], current_item_slot: int):
	for i in range(inventory_slots.size()):
		inventory_slots[i].set_texture(items[i].hud_icon if i < items.size() else null)
		inventory_slots[i].modulate_texture(Color.AQUAMARINE if i == current_item_slot else Color.WHITE)
