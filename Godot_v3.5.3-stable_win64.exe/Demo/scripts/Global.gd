extends Node

var frames: int
var timer: float


func _process(delta):
	if timer > 1.0:
		OS.set_window_title("Godot 3.5.2 FPS: "+str(frames))
		timer = 0.0
		frames = 0
	timer += delta
	frames += 1
