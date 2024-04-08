extends Spatial


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_pressed("forward"):
		translate(Vector3(0,0,-5.0*delta))
	if Input.is_action_pressed("backwards"):
		translate(Vector3(0,0,5.0*delta))
	if Input.is_action_pressed("left"):
		translate(Vector3(-5.0*delta,0,0))
	if Input.is_action_pressed("right"):
		translate(Vector3(5.0*delta,0,0))
	if Input.is_action_pressed("up"):
		translate(Vector3(0,5.0*delta,0))
	if Input.is_action_pressed("down"):
		translate(Vector3(0,-5.0*delta,0))


func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x += -event.relative.y/5
		rotation_degrees.y += -event.relative.x/5
