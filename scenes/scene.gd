extends Spatial


var rail_pattern = RegEx.new()
func _ready():
	rail_pattern.compile("@?rail(@\\d+)?")


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
	
	if not container or not rail_pattern.search(container.collider.name):
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


var rail_scene = load("res://scenes/rail.tscn")
func process_duplicate(delta): 
	if not Input.is_action_just_pressed("duplicate"):
		return
	
	var container = intersect_mouse_ray()[0]
	
	if not container: return
		
	var spatial = container.collider as Spatial
	selected = rail_scene.instance() if spatial.name == "rail" else spatial.duplicate()
	spatial.get_parent().add_child(selected)

func intersect_mouse_ray(exclude = [], camera = $Camera, distance = 1000):
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var normal = camera.project_ray_normal(mouse_position)
	var to = from + normal * distance
	var space_state = get_world().direct_space_state
	return [space_state.intersect_ray(from, to, exclude, 0x7FFFFFFF, true, true), from, normal]
