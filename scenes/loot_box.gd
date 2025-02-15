class_name LootBox extends StaticBody3D

@export var item: Item

func open():
	queue_free()
