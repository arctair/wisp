extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	process_click_and_drag(delta)
	process_duplicate(delta)

var selected : Spatial
func process_click_and_drag(delta):
	if Input.is_action_just_pressed("click_and_drag"):
		var container = intersect_mouse_ray()[0]
		if not container: return
		selected = container.collider
		
	if Input.is_action_just_released("click_and_drag") or Input.is_action_just_released("duplicate"):
		selected = null
	
	if not selected: return
	
	var mouse_ray = intersect_mouse_ray([selected])
	var container = mouse_ray[0]
	var mouse_position_3d = mouse_ray[1]
	var mouse_normal = mouse_ray[2]
	
	if not container or container.collider.name != "rail":
		set_parent(selected, self)
		selected.transform.origin = mouse_position_3d + mouse_normal * 1
		return
		
	var rail = container.collider as Spatial
	var metersPerUnit = 0.04445
	var unitCount = rail.get("unitCount")
	var u = round((container.position.y - rail.transform.origin.y) / metersPerUnit - 0.5)
	u = clamp(u, -unitCount / 2, unitCount / 2 - 1)
	set_parent(selected, rail)
	selected.transform.origin = Vector3.UP * (u + 0.5) * metersPerUnit

func set_parent(target, parent):
	if target.get_parent() == parent: return
	target.get_parent().remove_child(target)
	parent.add_child(target)


func process_duplicate(delta): 
	if not Input.is_action_just_pressed("duplicate"):
		return
	
	var container = intersect_mouse_ray()[0]
	
	if not container: return
		
	var spatial = container.collider as Spatial
	selected = spatial
	spatial.get_parent().add_child(spatial.duplicate())

func intersect_mouse_ray(exclude = [], camera = $Camera, distance = 1000):
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var normal = camera.project_ray_normal(mouse_position)
	var to = from + normal * distance
	var space_state = get_world().direct_space_state
	return [space_state.intersect_ray(from, to, exclude, 0x7FFFFFFF, true, true), from, normal]
