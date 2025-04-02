class_name LoadingScreen extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var scene_path: String
var scene_load_status = 0
var progress = []

signal finished_loading_scene(scene_path: String)
func _process(delta: float) -> void:
	if not scene_path: return
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	print("loading: ", progress[0]*100)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		#var new_scene = ResourceLoader.load_threaded_get(scene_path)
		scene_path = ""
		print('yaya')
		finished_loading_scene.emit(scene_path)
		animation_player.play("end")

func begin_scene_load(new_scene_path: String):
	scene_path = new_scene_path
	animation_player.play("begin")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "begin":
		ResourceLoader.load_threaded_request(scene_path)
	if anim_name == "end":
		queue_free()
