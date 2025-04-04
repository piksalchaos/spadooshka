extends HBoxContainer

@onready var host_texture: TextureRect = $HostTexture
@onready var joined_texture: TextureRect = $JoinedTexture
@onready var ready_texture: TextureRect = $ReadyTexture

func _ready() -> void:
	if name == "1":
		host_texture.show()
		joined_texture.hide()
	else:
		joined_texture.show()
		host_texture.hide()

func set_is_ready(is_ready: bool):
	ready_texture.visible = is_ready
