@tool
class_name Rope extends MeshInstance3D

@export var start: Vector3:
	set(value):
		start = value
		update()
@export var end: Vector3:
	set(value):
		end = value
		update()
@export var thickness: float:
	set(value):
		thickness = value
		update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	if start == end:
		print("start and end points are identical!")
		transform = Transform3D()
		return
	if thickness == 0:
		print("thickness is zero!")
		transform = Transform3D()
		return
	if not abs((end - start).normalized().dot(Vector3.UP)) == 1:
		transform = Transform3D(Vector3.UP * thickness, end - start, Vector3.UP.cross(end - start).normalized() * thickness, (start + end)/2)
	else:
		transform = Transform3D(Vector3.RIGHT * thickness, end - start, Vector3.RIGHT.cross(end - start).normalized() * thickness, (start + end)/2)
