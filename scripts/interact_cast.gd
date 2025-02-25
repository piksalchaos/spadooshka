class_name InteractCast extends ShapeCast3D

var selected_body: PhysicsBody3D

func check_interact_cast():
	if not is_colliding():
		remove_selected_body()
		return
	if get_collision_count() == 1:
		print("one object")
		var target: PhysicsBody3D = get_collider(0)
		if target:
			set_selected_body(target)
	else:
		print('more than one ')
		var closest_selected_body = get_closest_selected_body()
		if closest_selected_body:
			set_selected_body(closest_selected_body)

func get_closest_selected_body() -> PhysicsBody3D:
	var closest_target: PhysicsBody3D
	var closest_target_distance: float = INF
	for i in range(get_collision_count()):
		var target: PhysicsBody3D = get_collider(i)
		if not target: continue
		var target_distance = global_position.distance_squared_to(target.global_position)
		if target_distance < closest_target_distance:
			closest_target_distance = target_distance
			closest_target = target
	return closest_target

func set_selected_body(new_selected_body: PhysicsBody3D):
	if selected_body == new_selected_body: return
	if not selected_body:
		selected_body = new_selected_body
		set_body_in_range(selected_body, true)
		return
	set_body_in_range(selected_body, false)
	selected_body = new_selected_body
	set_body_in_range(selected_body, true)

func remove_selected_body():
	if selected_body and is_instance_valid(selected_body):
		set_body_in_range(selected_body, false)
	selected_body = null

func set_body_in_range(body: PhysicsBody3D, is_in_range: bool):
	var interaction_component = body.get_node_or_null("InteractionComponent")
	if interaction_component:
			interaction_component.set_in_range(is_in_range)
