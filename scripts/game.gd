extends Node2D

@export var marble_scene : PackedScene
var marble_images := []
var shooter
const MAX_POWER := 5.0
var taking_shot : bool
const MOVE_THRESHOLD := 5.0
const START_POS := Vector2(590, 580)
var shooter_available : bool = true
var marble_count : int
var cpu_play : bool = false
var target
var current_count : int


func _ready() -> void:
	load_images()
	new_game()
	$PlayArea.body_exited.connect(marble_obtained)
	ai_play()

func load_images():
	for i in range(1, 6, 1):
		var filename = str("res://assets/balls/ball_",i,".png")
		var marble_image = load(filename)
		marble_images.append(marble_image)

func new_game():
	global.player_score = 0
	generate_marbles()
	reset_shooter()
	show_finger()
	
	
func _process(delta: float) -> void:
	if global.player_score == marble_count:
		game_over("win")
	if shooter.linear_velocity.length() > MOVE_THRESHOLD:
		shooter_available = false
	if((349 <= int(shooter.position.x) and int(shooter.position.x) <= 800) and 
	(32 <= int(shooter.position.y) and int(shooter.position.y) <= 485) and
	shooter.linear_velocity.length() <= MOVE_THRESHOLD):
		shooter.queue_free()
		reset_shooter()
		global.player_score -= 1
		shooter_available = true
		cpu_play = not cpu_play
		ai_play()


func generate_marbles():
	marble_count = randi_range(10, 15)
	current_count = marble_count
	#print("No of Marbles: " + str(ball_count))
	for count in range(marble_count):
		var m = marble_scene.instantiate()
		var default_pos = Vector2(576, 261)
		var x_pos_change = randi_range(-150, 150)
		var y_pos_change = randi_range(-150, 150)
		var pos = default_pos + Vector2(x_pos_change, y_pos_change)
		#print(pos)
		add_child(m)
		m.position = pos
		var marble_color = randi_range(0, len(marble_images) - 1)
		m.get_node("Sprite2D").texture = marble_images[marble_color]
		
		
	
func reset_shooter():
	shooter = marble_scene.instantiate()
	add_child(shooter)
	shooter.position = START_POS
	shooter.get_node("Sprite2D").texture = load("res://assets/balls/ball_16.png")
	
	

	
func marble_obtained(body):
	if body == shooter:	
		body.queue_free()
		reset_shooter()
		shooter_available = true
	else:
		if cpu_play:
			global.cpu_score += 1
		else:
			global.player_score += 1
		current_count -= 1
		$"Score Label".text = "Player Score: " + str(global.player_score)
		$"Score Label".text +="\nCPU Score: " + str(global.cpu_score)
		body.queue_free()
	cpu_play = not cpu_play
	

func _on_finger_shoot(power) -> void:
	if shooter_available:
		shooter.apply_central_impulse(power)


func show_finger():
	$Finger.set_process(true)
	$PowerBar.position.x = shooter.position.x - (0.5 * $PowerBar.size.x)
	$PowerBar.position.y = shooter.position.y + ($PowerBar.size.y)
	$Finger.position = shooter.position
	$Finger.show()
	$PowerBar.show()

func hide_finger():
	$Finger.set_process(false)
	
func game_over(outcome):
	$Hud.show()
	if outcome == "win":
		$Hud/ResultPanel/Label.text = "YOU WIN!"

func ai_play():
	if cpu_play:
		var select = randi_range(0, current_count)
		var m = get_tree().get_nodes_in_group("marble_scene")
		target = m[select]
		var dir = target.position - START_POS
		var power = dir * MAX_POWER
		#print(power)
		shooter.apply_central_impulse(power)
		
	
