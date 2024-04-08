extends Spatial

onready var plane: Spatial = get_parent()


func _process(_delta):
	global_rotation = plane.global_rotation
	global_translation = Vector3(plane.global_translation.x, plane.global_translation.y*0.1, plane.global_translation.z)
	global_scale(Vector3(1,0,1))
