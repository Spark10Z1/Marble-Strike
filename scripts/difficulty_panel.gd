extends Panel

func _ready() -> void:
	$Debug.text = ""

func next_screen():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_easy_button_pressed() -> void:
	global.diff_level = 10
	next_screen()
	

func _on_medium_button_pressed() -> void:
	global.diff_level = 20
	next_screen()


func _on_hard_button_pressed() -> void:
	global.diff_level = 40
	next_screen()
	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_player_button_pressed() -> void:
	global.two_player_mode = true
	next_screen()

func _on_how_to_play_button_pressed() -> void:
	$Debug.text = "NOT IMPLEMENTED YET!!!"
	await get_tree().create_timer(0.5).timeout
	$Debug.text = ""
