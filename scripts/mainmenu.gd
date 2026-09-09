extends Node2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func play_sound(sound):
	audio_player.stream = sound
	audio_player.play()

func _on_play_button_mouse_entered() -> void:
	play_sound(load("res://assets/sfx/Cursor1.wav"))

func _on_play_button_pressed() -> void:
	play_sound(load("res://assets/sfx/Select1.wav"))
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scenes/difficulty.tscn")


func _on_customize_button_mouse_entered() -> void:
	play_sound(load("res://assets/sfx/Cursor1.wav"))

func _on_customize_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_mouse_entered() -> void:
	play_sound(load("res://assets/sfx/Cursor1.wav"))

func _on_quit_button_pressed() -> void:
	play_sound(load("res://assets/sfx/Select1.wav"))
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()
