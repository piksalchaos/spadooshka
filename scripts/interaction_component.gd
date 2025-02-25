class_name InteractionComponent extends Node


@export var mesh_to_highlight: MeshInstance3D
const highlight_material = preload("res://resources/materials/interaction_highlight.tres")

func set_in_range(is_in_range: bool):
	if is_in_range:
		mesh_to_highlight.material_overlay = highlight_material
	else:
		mesh_to_highlight.material_overlay = null
