extends Node

var multiplayer_container: Node = null

@rpc("any_peer", "call_local", "reliable")
func spawn_with_data_as_server(data: Dictionary):
	if not multiplayer.is_server(): return
	var node = load(data.path).instantiate()
	var has_server_rpc = data.has("server_rpc")
	
	if data.has("props"):
		for prop_name in data.props.keys():
			node.set(prop_name, data.props[prop_name])
	if data.has("methods"):
		for method_name in data.methods.keys():
			node.callv(method_name, data.methods[method_name])
	
	multiplayer_container.add_child(node, true)
	
	if data.has("server_rpc"):
		for server_rpc_name in data.server_rpc.keys():
			rpc(server_rpc_name, node, data.server_rpc[server_rpc_name])

func spawn_with_data(data: Dictionary):
	spawn_with_data_as_server.rpc_id(1, data)

@rpc("authority", "call_local")
func add_collision_exception_with_remotely(node: Node3D, data: Dictionary):
	var target = get_node_or_null(data["exception_path"])
	if target and node is PhysicsBody3D:
		node.add_collision_exception_with(target)
		print(node.get_collision_exceptions(), "<- asldfjsf")
		node.set_collision_layer_value(1, true)
