class_name InteractCast extends ShapeCast3D

var target_body: PhysicsBody3D
signal interacted(target: PhysicsBody3D)

func _process(_delta: float) -> void:
	if not is_colliding():
		remove_target_body()
		return
	if get_collision_count() == 1:
		var target: PhysicsBody3D = get_collider(0)
		if target:
			set_target_body(target)
	else:
		var closest_target_body = get_closest_target_body()
		if closest_target_body:
			set_target_body(closest_target_body)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and target_body:
		if target_body.get_node_or_null("InteractionComponent"):
			interacted.emit(target_body)

func get_closest_target_body() -> PhysicsBody3D:
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

func set_target_body(new_target_body: PhysicsBody3D):
	if target_body == new_target_body: return
	if not target_body:
		target_body = new_target_body
		set_body_in_range(target_body, true)
		return
	set_body_in_range(target_body, false)
	target_body = new_target_body
	set_body_in_range(target_body, true)

func remove_target_body():
	if target_body and is_instance_valid(target_body):
		set_body_in_range(target_body, false)
	target_body = null

func set_body_in_range(body: PhysicsBody3D, is_in_range: bool):
	var interaction_component = body.get_node_or_null("InteractionComponent")
	if interaction_component:
			interaction_component.set_in_range(is_in_range)
