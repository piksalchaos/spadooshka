extends TextureRect

@onready var p1_score_label: Label = $LabelHBoxContainer/P1ScoreContainer/P1ScoreLabel
@onready var p2_score_label: Label = $LabelHBoxContainer/P2ScoreContainer/P2ScoreLabel
@onready var p1_score_bar: TextureProgressBar = $LabelHBoxContainer/ScoreBars/P1ScoreBar
@onready var p2_score_bar: TextureProgressBar = $LabelHBoxContainer/ScoreBars/P2ScoreBar

func set_P1_score_label(score: int):
	p1_score_label.text = str(score)
	p1_score_bar.value = score

func set_P2_score_label(score: int):
	p2_score_label.text = str(score)
	p2_score_bar.value = score
