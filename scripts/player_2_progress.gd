extends ProgressBar
func _process(_delta: float) -> void:
	value = global.player2_score
	max_value = global.marble_count
