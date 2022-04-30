extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var camera = $Camera
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000
	var space_state = get_world().direct_space_state
	var container = space_state.intersect_ray(from, to, [], 0x7FFFFFFF, true, true)
	
	if container and container.collider == $rail_12u/Area:
		var u = round((container.position.y - $rail_12u.transform.origin.y) / 0.04445 - 0.5) + 7
		u = clamp(u, 1, 12)
		$rail_12u/simplomatic.transform.origin = Vector3(0, (u - 7) * 0.04445 + 0.04445 / 2, 0)
	else:
		$rail_12u/simplomatic.transform.origin = from + camera.project_ray_normal(mouse_position) * 1
