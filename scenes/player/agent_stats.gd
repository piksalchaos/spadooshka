class_name AgentStats extends Resource

# default values
@export var max_health: int = 100

@export var default_speed: float = 14
@export var dash_speed: float = 50.0
@export var boosted_speed: float = 30.0
@export var is_slow_while_shooting: bool = false

@export var default_jump_velocity: float = 11.0
@export var wall_jump_velocity: float = 25.0
@export var boosted_jump_velocity: float = 18.0

@export var player_icon: CompressedTexture2D
