@tool
extends MeshInstance3D

@export var a: float:
	set(value):
		notify_property_list_changed()
		mesh.material.set_shader_parameter("a", value)
		a = value
@export var b: float:
	set(value):
		notify_property_list_changed()
		mesh.material.set_shader_parameter("b", value)
		b = value
@export var c: float:
	set(value):
		notify_property_list_changed()
		mesh.material.set_shader_parameter("c", value)
		c = value
