class_name AirplaneControl
extends RigidBody

export var cameraPivot: NodePath
export var rotationSensitivity: float = 2.5
export var aggresiveTurnFactor: float = 1.5
var camPiv: Spatial
var secPiv: Spatial
var camera: Camera
var target: Spatial
var particle0: Spatial
var particle1: Spatial

var throttle: float
var roll: float

var cameraLocked: bool = true


func _ready():
	camPiv = get_node(cameraPivot)
	secPiv = camPiv.get_node("secondPivot")
	camera = secPiv.get_node("Camera")
	target = camPiv.get_node("target")
	particle0 = get_node("thrusterRight")
	particle1 = get_node("thrusterLeft")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta):
	if Input.is_action_pressed("forward"):
		throttle += 10.0*delta
	if Input.is_action_pressed("backwards"):
		throttle += -10.0*delta
	throttle = clamp(throttle, 0.0, 100.0)
	var pScale: float = throttle/100.0
	particle0.scale = Vector3(pScale, pScale, pScale)
	particle1.scale = Vector3(pScale, pScale, pScale)
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		roll += 2.0*delta
	elif !Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		roll += -2.0*delta
	else:
		if roll > 0.0:
			roll -= 2.0*delta
		if roll < 0.0:
			roll += 2.0*delta
	roll = clamp(roll, -5.0, 5.0)
	if cameraLocked and secPiv.rotation_degrees != Vector3(0,0,0):
		secPiv.rotation_degrees += Vector3(-secPiv.rotation_degrees.x*(delta/0.25),-secPiv.rotation_degrees.y*(delta/0.25),-secPiv.rotation_degrees.z*(delta/0.25))


func _physics_process(_delta):
	airplane_controls()


func _input(event):
	if Input.is_action_just_pressed("freeCamera"):
		cameraLocked = false
	if Input.is_action_just_released("freeCamera"):
		cameraLocked = true
	if event is InputEventMouseMotion:
		if cameraLocked:
			camPiv.rotation_degrees.x -= event.relative.y/5
			camPiv.rotation_degrees.y -= event.relative.x/5
			if secPiv.rotation_degrees == Vector3(0,0,0):
				camera.look_at(target.global_translation+Vector3(0,6,0),Vector3.UP)
		else:
			secPiv.rotation_degrees.x -= event.relative.y/5
			secPiv.rotation_degrees.y -= event.relative.x/5
	if event is InputEventMouseButton:
		if event.button_index == 4:
			camera.translation.z += -0.25
		if event.button_index == 5:
			camera.translation.z += 0.25
		camera.translation.z = clamp(camera.translation.z, 5.0,25.0)
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func airplane_controls():
	$HUD/topleft/throttle.text = "Throttle: "+str(throttle)
	camPiv.global_translation = global_translation
	secPiv.global_translation = global_translation+Vector3(0,2.5,0)
	linear_velocity = to_global(Vector3(0,0,-throttle))-global_translation
	var targetDirection: Vector3 = to_local(target.global_translation).normalized().rotated(Vector3(0,0,1),rotation.z)
	$HUD/topleft/targetDirection.text = "Target Direction: "+str(targetDirection)
	var angleOffTarget: float = (to_global(Vector3.FORWARD)-global_translation).angle_to(target.global_translation - global_translation)
	$HUD/topleft/angleTo.text = "Angle to Target: "+str(angleOffTarget)
	var aggressiveRoll: float = clamp(targetDirection.x,-1.0,1.0)
	var levelRoll: float = rotation.z
	var rollInfluence: float = inverse_lerp(0.0,aggresiveTurnFactor,angleOffTarget)
	var zRoll: float
	if roll < 0.1 and roll > -0.1:
		zRoll = lerp(levelRoll,aggressiveRoll,rollInfluence)
		$HUD/topleft/roll.text = "Roll(Auto): "+str(zRoll)
	else:
		zRoll = -clamp(roll,-1.0,1.0)
		$HUD/topleft/roll.text = "Roll(Manual): "+str(zRoll)
	var xPitch: float = clamp(targetDirection.y,-1.0,1.0)
	$HUD/topleft/pitch.text = "Pitch: "+str(xPitch)
	var yYaw: float = clamp(targetDirection.x,-1.0,1.0)
	$HUD/topleft/yaw.text = "Yaw: "+str(yYaw)
	angular_velocity = Vector3(0,0,0)
	rotation_degrees += Vector3(xPitch,-yYaw,-zRoll)*rotationSensitivity
	$HUD/direction.visible = camera.is_position_behind(to_global(Vector3(0,0,50)))
	$HUD/direction.rect_position = camera.unproject_position(to_global(Vector3(0,0,50)))
