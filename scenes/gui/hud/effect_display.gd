extends VBoxContainer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var texture_rect: TextureRect = $TextureRect

@export var effect: Effect

func _ready():
	if not effect: return
	texture_rect.texture = effect.icon
	effect.tree_exited.connect(_on_effect_tree_exited)

func _process(_delta: float) -> void:
	if effect is TemporaryEffect:
		progress_bar.value = effect.timer.time_left / effect.timer.wait_time * 100

func _on_effect_tree_exited():
	queue_free()
