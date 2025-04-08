extends Node

var loading_scene_paths: Array[String]

signal began_loading_scene(scene_path: String)
signal still_loading_scene(scene_path: String)
signal finished_loading_scene(scene_path: String)

func _process(delta: float) -> void:
	for i in loading_scene_paths.size():
		handle_loading_scene(i)

func handle_loading_scene(index: int):
	var scene_path = loading_scene_paths[index]
	var scene_load_status = ResourceLoader.load_threaded_get_status(scene_path)
	match scene_load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			still_loading_scene.emit(scene_path)
		ResourceLoader.THREAD_LOAD_LOADED:
			finished_loading_scene.emit(scene_path)
			loading_scene_paths.pop_at(index)

func request_scene_load(scene_path: String):
	loading_scene_paths.append(scene_path)
	ResourceLoader.load_threaded_request(scene_path)
	began_loading_scene.emit(scene_path)
