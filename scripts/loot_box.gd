class_name LootBox extends StaticBody3D

var item: Item

func obtain_item():
	self.queue_free()
	return item
