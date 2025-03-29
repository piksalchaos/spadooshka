extends Node

var multiplayer_container = null

func add_node_to_multiplayer_container(node: Node):
	multiplayer_container.add_child(node)
