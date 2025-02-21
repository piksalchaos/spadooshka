extends AspectRatioContainer

@onready var texture_rect: TextureRect = $MarginAdjuster/MarginContainer/TextureRect

func set_texture(texture: Texture2D):
	texture_rect.texture = texture

func modulate_texture(color: Color):
	texture_rect.modulate = color
