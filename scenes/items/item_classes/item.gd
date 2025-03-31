class_name Item extends Node3D

@onready var player: CharacterBody3D
@export var item_name: String
@export var hud_icon: Texture2D
@export var is_selected: bool

func use() -> bool:
	queue_free()
	return true

func _enter_tree() -> void:
	self.name = item_name
