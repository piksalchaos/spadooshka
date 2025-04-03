extends Control

@onready var loading_screen: LoadingScreen = $LoadingScreen

@onready var title_screen: Control = $TitleScreen
@onready var pre_game_menu: Control = $PreGameMenu
@onready var agent_map_select_menu: Control = $AgentMapSelectMenu
@onready var preliminary_screen: Control = $PreliminaryScreen
@onready var hud: HUD = $HUD
@onready var victory_screen: Control = $VictoryScreen
@onready var defeat_screen: Control = $DefeatScreen

var next_node_to_hide
var next_node_to_show
var peer_ready_states = {}

# ik there's a lot of hardcoding and there's no modularity, but deal with it for now lol

func start_gui_transition(node_to_hide, node_to_show):
	next_node_to_hide = node_to_hide
	next_node_to_show = node_to_show
	loading_screen.fade_to_black()

func _on_loading_screen_faded_to_black() -> void:
	next_node_to_hide.hide()
	next_node_to_show.show()
	loading_screen.fade_to_transparent()

func _on_title_screen_start_button_pressed() -> void:
	start_gui_transition(title_screen, pre_game_menu)

func _on_pre_game_menu_back_button_pressed() -> void:
	start_gui_transition(pre_game_menu, title_screen)

func _on_pre_game_menu_lobby_start_button_pressed() -> void:
	begin_agent_map_selection.rpc()

@rpc("call_local", "reliable")
func begin_agent_map_selection():
	start_gui_transition(pre_game_menu, agent_map_select_menu)
	#lobby_menu.hide()
	#agent_map_select_menu.show()

func _on_agent_map_select_menu_finished_selection(
		_peer_id: int, _agent_name: String, _map_name: String
	) -> void:
	agent_map_select_menu.hide()
	preliminary_screen.show()

func _on_preliminary_screen_back_button_pressed() -> void:
	preliminary_screen.hide()
	agent_map_select_menu.show()

func _on_preliminary_screen_begin_button_pressed() -> void:
	prepare_for_game.rpc()

@rpc("call_local", "reliable")
func prepare_for_game():
	preliminary_screen.hide()
	hud.show()

@rpc("call_local", "reliable")
func prepare_for_end_game(P1_won: bool):
	hud.hide()
	if is_multiplayer_authority() == P1_won:
		victory_screen.show()
	else:
		defeat_screen.show()
