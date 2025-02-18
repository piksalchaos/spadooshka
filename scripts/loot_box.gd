class_name LootBox extends StaticBody3D

var item: Item

func obtain_item():
	queue_free()
	return item
