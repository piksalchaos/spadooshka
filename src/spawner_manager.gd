extends Node

var multiplayer_container = null

@rpc("any_peer", "call_local", "reliable")
func add_child_to_multiplayer_container(node: Node):
	multiplayer_container.add_child(node)

@rpc("any_peer", "call_local", "reliable")
func spawn_with_data_as_server(data: Dictionary):
	if not multiplayer.is_server(): return
	var node = load(data.path).instantiate()
	if data.has("props"):
		for prop_name in data.props.keys():
			node.set(prop_name, data.props[prop_name])
	if data.has("methods"):
		for method_name in data.methods.keys():
			node.callv(method_name, data.methods[method_name])
	multiplayer_container.add_child(node, true)

func spawn_with_data(data: Dictionary):
	spawn_with_data_as_server.rpc_id(1, data)
