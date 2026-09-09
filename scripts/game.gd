extends Node2D

@export var marble_scene : PackedScene
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var marble_images := []
var shooter
const MAX_POWER := 4.5
var taking_shot : bool
const MOVE_THRESHOLD := 5.0
const START_POS := Vector2(580, 615)
const AREA_POS := Vector2(576, 346)

var shooter_available : bool = true

var marble_count : int
var current_count : int
var target
var player1_play : bool = true
var shooter_out : bool = false
var marble_out : bool = false
var proceed_play : bool = true

#PreLoad Sounds
var Reset_Sound = preload("res://sounds/Reset.wav")
var CPU_Point_Sound = preload("res://sounds/CPU_Point.wav")
var Player_Point_Sound = preload("res://sounds/Player_Point.wav")
var Lose_Sound = preload("res://sounds/Lose.wav")
var Tie_Sound = preload("res://sounds/Tie.wav")
var Win_Sound = preload("res://sounds/Win.wav")

func _ready() -> void:
	load_images()
	new_game()
	$PlayArea.body_exited.connect(marble_obtained)

func load_images():
	for i in range(1, 18, 1):
		#var filename = str("res://assets/marbles/ms_",i,".png")
		var filename = str("res://assets/balls/",i,".png")
		var marble_image = load(filename)
		marble_images.append(marble_image)

func new_game():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	global.player1_score = 0
	global.player2_score = 0
	generate_marbles()
	reset_shooter()
	show_finger()
	show_score()

func _process(_delta: float) -> void:
	if player1_play:
		$"Current_Player Label".text = "PLAYER2 PLAYS!!"
	else:
		$"Current_Player Label".text = "PLAYER1 PLAYS!!"
	for m in get_tree().get_nodes_in_group("marble_scene"):
		if(m.linear_velocity.length() > 0.0  and 
		m.linear_velocity.length() < MOVE_THRESHOLD):
			m.sleeping = true			
		elif m.linear_velocity.length() >= MOVE_THRESHOLD:
			shooter_available = false			
	if current_count == 0 or abs(global.player2_score - global.player1_score) > current_count:
		game_over()
	if shooter.linear_velocity.length() > MOVE_THRESHOLD:
		shooter_available = false
	if(shooter.position!= START_POS and shooter.linear_velocity.length() <= MOVE_THRESHOLD/2):
		shooter.queue_free()
		reset_shooter()
	
func generate_marbles():
	marble_count = randi_range(25, 35)
	current_count = marble_count
	for count in range(marble_count):
		var marble_instance = marble_scene.instantiate()
		var default_pos = AREA_POS
		var x_pos_change = randi_range(-160, 160)
		var y_pos_change = randi_range(-160, 160)
		var pos = default_pos + Vector2(x_pos_change, y_pos_change)
		add_child(marble_instance)
		marble_instance.position = pos
		var marble_color = randi_range(0, len(marble_images) - 1)
		marble_instance.get_node("Sprite2D").texture = marble_images[marble_color]

func play_sound(sound):
	audio_player.stream = sound
	audio_player.play()		

func reset_shooter():
	shooter = marble_scene.instantiate()
	add_child(shooter)
	shooter.position = START_POS
	#shooter.get_node("Sprite2D").texture = load("res://assets/balls/ball_16.png")
	shooter.get_node("Sprite2D").texture = load("res://assets/marbles/ms_1.png")
	shooter.set_collision_layer_value(3, true)
	shooter.set_collision_layer_value(2, false)
	shooter.set_collision_mask_value(4, true)
	shooter_available = true
	change_player()
	marble_out = false
	if player1_play:
		if not global.two_player_mode:
			bot_play()
		else:
			show_finger()
			play_sound(Reset_Sound)
	else:
		if proceed_play:
			show_finger()
			play_sound(Reset_Sound)
	
	#Auto Difficulty Adjustment
	if(abs(global.player2_score - global.player1_score) > 2):
		if global.player2_score > global.player1_score:
			global.diff_level -= 5
		else:
			global.diff_level += 5
	
func marble_obtained(body):
	update_score()
	body.queue_free()
	marble_out = true

func show_finger():
	$Finger.set_process(true)
	#$PowerBar.position.x = shooter.position.x - (0.5 * $PowerBar.size.x)
	#$PowerBar.position.y = shooter.position.y + ($PowerBar.size.y)
	$Finger.position = shooter.position
	$Finger.show()
	$PowerBar.show()

func hide_finger():
	$Finger.set_process(false)
	$Finger.hide()
	$PowerBar.hide()
	
func _on_finger_shoot(power) -> void:
	if shooter.position == START_POS and proceed_play:
		shooter_out = false
		marble_out = false
		shooter_available = true
		shooter.apply_central_impulse(power)
		hide_finger()

func show_score():
	$"Score Label".text = "Player1 Score: " + str(global.player1_score)
	$"Score Label".text +="\nPlayer2 Score: " + str(global.player2_score)
	$"Score Label".text +="\nRemaining Marbles: " + str(current_count)	

func update_score():
	if player1_play:
		global.player2_score += 1
		play_sound(CPU_Point_Sound)
	else:
		global.player1_score += 1
		play_sound(Player_Point_Sound)
	current_count -= 1
	show_score()

func bot_play():
	hide_finger()
	var select = randi_range(0, current_count)
	var m = get_tree().get_nodes_in_group("marble_scene")
	target = m[select]
	var miss_range : int = 100 - global.diff_level
	var miss_chance : float = randf_range(0, 100)
	var dir
	var power
	if miss_chance < miss_range:
		var x_miss : int = randi_range(-25, 25)
		var y_miss : int = randi_range(-25, 25)
		var pow_miss : float = randf_range(0.75,1)
		dir = target.position - START_POS + Vector2(x_miss, y_miss)
		power = dir * MAX_POWER * pow_miss
	else:
		dir = target.position - START_POS
		power = dir * MAX_POWER
	if global.diff_level >= 50:
		dir = target.position - START_POS
		power = dir * MAX_POWER
	if shooter_available and proceed_play:
		shooter.apply_central_impulse(power)
	shooter_available = false
	
func change_player():
	if(not marble_out):
		player1_play = not player1_play
	
func game_over():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hide_finger()
	var game_over_sounds = [Win_Sound, Tie_Sound, Lose_Sound]
	var result : int
	if global.player1_score > global.player2_score:
		$Hud/ResultPanel/Label.text = "Player1 WINS!"
		result = 0
	elif global.player1_score == global.player2_score:
		$Hud/ResultPanel/Label.text = "TIE!"
		result = 1
	else:
		$Hud/ResultPanel/Label.text = "Player2 WINS!"
		result = 2
	if proceed_play:
		play_sound(game_over_sounds[result])
	$Hud.show()
	proceed_play = false
