@tool
extends Control



const DEFAULT_SIZE = Vector2(100, 100)

const DOT_RADIUS = 2.0

const LINE_WIDTH = 1.0
const LINE_LENGTH = 6.0
const DEFAULT_LINE_CENTER_DISTANCE = 18.0
const DEFAULT_SHOOT_OFFSET_DISTANCE = 5.0
const SHOOT_OFFSET_DISTANCE_TWEEN_INTERVAL = 0.15
const DEFAULT_AIM_OFFSET_DISTANCE = -10.0
const AIM_OFFSET_DISTANCE_TWEEN_INTERVAL = 0.1

const CROSSHAIR_LINE_POLYGON_POINTS = [
	Vector2(0, 0),
	Vector2(6, 2),
	Vector2(10, 0),
	Vector2(6, -2)
]

var line_center_distance = 18.0
var shoot_offset_distance: float = 0.0
var shoot_offset_distance_tween: Tween
var aim_offset_distance: float = 0.0
var aim_offset_distance_tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("aim"):
		start_aim_animation()
	if event.is_action_released("aim"):
		end_aim_animation()
func _process(delta: float) -> void:
	line_center_distance = DEFAULT_LINE_CENTER_DISTANCE + shoot_offset_distance + aim_offset_distance
	queue_redraw()
func _draw():
	draw_circle(size/2, DOT_RADIUS, Color.WHITE)
	draw_set_transform(size/2, 0.0, size/DEFAULT_SIZE)
	draw_crosshair_lines()

func draw_crosshair_lines():
	for i in 4:
		var line_rotation = i*PI/2
		var center_offset = Vector2.RIGHT.rotated(line_rotation)*line_center_distance
		var polygon_points = []
		for point in CROSSHAIR_LINE_POLYGON_POINTS:
			polygon_points.append(center_offset + point.rotated(line_rotation))
		draw_colored_polygon(polygon_points, Color.WHITE)

# lol ignore this super repetitive code like im lazy
func start_shoot_animation():
	if shoot_offset_distance_tween:
		shoot_offset_distance_tween.stop()
	shoot_offset_distance_tween = get_tree().create_tween()
	
	shoot_offset_distance = DEFAULT_SHOOT_OFFSET_DISTANCE
	shoot_offset_distance_tween.tween_property(
		self, "shoot_offset_distance", 0.0, SHOOT_OFFSET_DISTANCE_TWEEN_INTERVAL
	).set_ease(Tween.EASE_OUT)

func start_aim_animation():
	if aim_offset_distance_tween:
		aim_offset_distance_tween.stop()
	aim_offset_distance_tween = get_tree().create_tween()
	
	aim_offset_distance_tween.tween_property(
		self, "aim_offset_distance",
		DEFAULT_AIM_OFFSET_DISTANCE, AIM_OFFSET_DISTANCE_TWEEN_INTERVAL
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func end_aim_animation():
	if aim_offset_distance_tween:
		aim_offset_distance_tween.stop()
	aim_offset_distance_tween = get_tree().create_tween()
	
	aim_offset_distance_tween.tween_property(
		self, "aim_offset_distance",
		0.0, AIM_OFFSET_DISTANCE_TWEEN_INTERVAL
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
