extends PanelContainer

@onready var P1_score_label: Label = $LabelHBoxContainer/P1ScoreLabel
@onready var P2_score_label: Label = $LabelHBoxContainer/P2ScoreLabel
@onready var round_label: Label = $LabelHBoxContainer/RoundLabel

func set_P1_score_label(score: int):
	P1_score_label.text = str(score)

func set_P2_score_label(score: int):
	P2_score_label.text = str(score)

func set_round_label(round_number: int):
	round_label.text = "Round " + str(round_number)
