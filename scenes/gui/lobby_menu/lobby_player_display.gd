extends VBoxContainer

@onready var ready_label: Label = $ReadyLabel
@onready var server_state_label: Label = $ServerStateLabel

func _ready() -> void:
	server_state_label.text = "Hosting" if name == "1" else "Joined"
	#server_state_label.text = name

func set_is_ready(is_ready: bool):
	ready_label.text = "Ready" if is_ready else "Not Ready"
