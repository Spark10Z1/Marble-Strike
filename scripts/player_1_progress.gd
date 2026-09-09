extends ProgressBar
func _process(_delta: float) -> void:
	value = global.player1_score
	max_value = global.marble_count
