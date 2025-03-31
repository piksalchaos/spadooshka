class_name HUD extends Node

@onready var player_icon: TextureRect = $PlayerStatus/PlayerIcon
@onready var ammo_amount_bar: TextureProgressBar = $AspectRatioContainer/AmmoAmountBar
@onready var health_bar: TextureProgressBar = $PlayerStatus/MarginAdjuster/BarVBoxContainer/HealthBar
@onready var dash_bar: TextureProgressBar = $PlayerStatus/MarginAdjuster/BarVBoxContainer/DashBar
@onready var bubble_shield_bar: ProgressBar = $PlayerStatus/MarginAdjuster/BarVBoxContainer/BubbleShieldBar
const EFFECT_DISPLAY_SCENE = preload("res://scenes/gui/hud/effect_display.tscn")
@onready var effects_display: HBoxContainer = $EffectsDisplay
@onready var inventory_slots: Array[Node] = $Inventory.get_children()
@onready var low_health_texture = $LowHealthTexture
@onready var low_health_texture_animation_player = $LowHealthTexture/AnimationPlayer

@onready var score_display: TextureRect = $ScoreDisplay

@onready var win_icon = $RoundWonIcon
@onready var lost_icon = $RoundLostIcon

@export var low_health_effect_threshold = 0.25

const HEALTH_BAR_MAX_TO_TEXTURE_RATIO = 0.95
var is_low_health = false

func update_player_icon(image: CompressedTexture2D):
	player_icon.texture = image

func update_ammo_display(num_bullets, mag_capacity):
	ammo_amount_bar.value = float(num_bullets) / mag_capacity

func update_health_display(health, max_health):
	health_bar.value = float(health) / max_health * HEALTH_BAR_MAX_TO_TEXTURE_RATIO
	#if low_health_texture_animation_player.is_playing():
		#return
	if float(health) / max_health < low_health_effect_threshold and is_low_health == false:
		is_low_health = true
		low_health_texture_animation_player.speed_scale = 1
		low_health_texture_animation_player.play("low_health_show")
	elif is_low_health == true:
		is_low_health = false
		low_health_texture_animation_player.speed_scale = -1
		low_health_texture_animation_player.play("low_health_show")
	

func update_dash_display(dash_value, max_dash):
	dash_bar.value = dash_value / max_dash

func create_effect_display(effect: Effect):
	if effect.effect_name == "Bubble Shield":
		create_bubble_shield_bar(effect)
		return
	
	var effect_display = EFFECT_DISPLAY_SCENE.instantiate()
	effect_display.effect = effect
	effects_display.add_child(effect_display)

func create_bubble_shield_bar(bubble_shield_effect: Effect):
	bubble_shield_bar.start(bubble_shield_effect)

func update_inventory_icons(items: Array[Item], current_item_slot: int):
	for i in range(inventory_slots.size()):
		var slot = inventory_slots[i]
		slot.icon.texture = items[i].hud_icon if i < items.size() else null
		#slot.icon.modulate = Color.AQUAMARINE if i == current_item_slot else Color.WHITE
		slot.outline_rect.visible = i == current_item_slot and items.size() > 0

@rpc("any_peer", "call_local")
func update_score_display(round_number: int, P1_score: int, P2_score: int):
	score_display.set_P1_score_label(P1_score)
	score_display.set_P2_score_label(P2_score)
	
func update_win_lost_display(is_win: bool):
	if is_win == null:
		win_icon.visible = false
		lost_icon.visible = false
		return
	if is_win:
		win_icon.visible = true
	else:
		lost_icon.visible = true
