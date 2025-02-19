class_name HUD extends Node

@onready var ammo_amount_bar: ProgressBar = $AmmoAmountBar
@onready var health_bar: ProgressBar = $PlayerStatus/AspectRatioContainer/BarVBoxContainer/HealthBar
@onready var dash_bar: ProgressBar = $PlayerStatus/AspectRatioContainer/BarVBoxContainer/DashBar

func update_ammo_display(num_bullets, mag_capacity):
	ammo_amount_bar.value = (float(num_bullets) / mag_capacity)
