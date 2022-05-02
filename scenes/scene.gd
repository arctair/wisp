extends Spatial


func _physics_process(delta):
	process_click_and_drag()
	process_duplicate()


var selected : Spatial
func process_click_and_drag():
	if Input.is_action_just_pressed("click_and_drag"):
		var container = intersect_mouse_ray()[0]
		if not container: return
		var node = container.collider as Node
		if node.is_in_group("ports"):
			node = node.get_parent()
		if node.is_in_group("movable"):
			selected = node
		
	if Input.is_action_just_released("click_and_drag") or Input.is_action_just_released("duplicate"):
		selected = null
	
	if not selected: return
	
	var mouse_ray = intersect_mouse_ray([selected])
	var container = mouse_ray[0]
	var mouse_position_3d = mouse_ray[1]
	var mouse_normal = mouse_ray[2]
	
	if container and selected.is_in_group("simplomatic") and container.collider.is_in_group("rail"):
		var rail = container.collider as Spatial
		var metersPerUnit = 0.04445
		var unitCount = rail.get("unitCount")
		var u = round((container.position.y - rail.transform.origin.y) / metersPerUnit - 0.5)
		u = clamp(u, -unitCount / 2, unitCount / 2 - 1)
		set_parent(selected, rail)
		selected.transform.origin = Vector3.UP * (u + 0.5) * metersPerUnit
		selected.rotation = Vector3.ZERO
	elif container and selected.is_in_group("plug") and container.collider.is_in_group("ports"):
		var ports = container.collider as Spatial
		var d = container.position - ports.global_transform.origin
		var portWidth = 0.017
		var portHeight = 0.017
		var port_x = clamp(round(d.x / portWidth - 0.5), -4, 3)
		var port_y = clamp(round(d.y / portHeight - 0.5), -1, 0)
		set_parent(selected, ports)
		
		selected.transform = ports.transform.translated(
			Vector3(
				(0.5 + port_x) * portWidth,
				(0.5 + port_y) * portHeight,
				0
			) - ports.transform.origin
		)
	else:
		set_parent(selected, self)
		selected.transform.origin = mouse_position_3d + mouse_normal * 2
		selected.transform = selected.transform.looking_at(selected.transform.origin + mouse_normal - mouse_normal.y * Vector3.UP, Vector3.UP)


func set_parent(target, parent):
	if target.get_parent() == parent: return
	target.get_parent().remove_child(target)
	parent.add_child(target)


func process_duplicate(): 
	if not Input.is_action_just_pressed("duplicate"): return
	
	var container = intersect_mouse_ray()[0]
	if not container: return
	
	var node = container.collider as Node
	var duplicate = try_duplicate(node)
	if not duplicate: return
	
	node.get_parent().add_child(duplicate)
	selected = duplicate
	
	
var duplicableScenesByGroupName = {
	"rail":  load("res://scenes/rail.tscn"),
	"simplomatic": load("res://scenes/simplomatic.tscn"),
	"plug": load("res://scenes/plug.tscn")
}
func try_duplicate(node : Node):
	for group_name in duplicableScenesByGroupName:
		if node.is_in_group(group_name):
			return duplicableScenesByGroupName[group_name].instance()
	return null


func intersect_mouse_ray(exclude = [], camera = $Camera, distance = 1000):
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var normal = camera.project_ray_normal(mouse_position)
	var to = from + normal * distance
	var space_state = get_world().direct_space_state
	return [space_state.intersect_ray(from, to, exclude, 0x7FFFFFFF, true, true), from, normal]
