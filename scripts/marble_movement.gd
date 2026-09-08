extends CharacterBody2D
var speed = 200
var direction = Vector2(1,1).normalized()
var images = []
var images_count : int = 30


func _ready() -> void:
	for i in range(1, images_count, 1):
		var filename = str("res://assets/marbles/ms_",i,".png")
		var marble_image = load(filename)
		images.append(marble_image)
	var color = randi_range(0, images_count - 2)
	get_node("Sprite2D").texture = images[color]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity = direction * speed
	rotation_degrees += 1
	rotation += 0.05
	var _collision = move_and_slide()	
	if get_slide_collision_count()>0:
		speed += 5
		var hit = get_slide_collision(0)		
		direction = direction.bounce(hit.get_normal())
