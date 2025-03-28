@tool
extends Container

@export var height_to_width_ratio: float = 0.5625
@export var columns: int = 2
@export var inner_margin_pixels: int = 10

signal icon_selected(icon_name: String)

func _ready():
	sort_children()
	if not Engine.is_editor_hint():
		for selectable_icon in get_children():
			selectable_icon.selected.connect(_on_selectable_icon_selected)

func _on_selectable_icon_selected(icon_name: String):
	icon_selected.emit(icon_name)
	for icon in get_children():
		if icon.name == icon_name: continue
		icon.button_pressed = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		sort_children()

func sort_children():
	for i in range(get_child_count()):
		var icon_width = (size.x - inner_margin_pixels*(columns-1))/columns
		var icon_height = icon_width / height_to_width_ratio
		var icon_x = (i % columns) * (icon_width + inner_margin_pixels)
		var icon_y = floorf(float(i)/columns) * (icon_height + inner_margin_pixels)
		
		fit_child_in_rect(
			get_child(i),
			Rect2(icon_x, icon_y, icon_width, icon_height)
		)
