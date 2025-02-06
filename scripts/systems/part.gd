extends Area2D

var dragging = false
var offset = Vector2.ZERO

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			offset = global_position - event.global_position
			print("Part selected for dragging at:", global_position)  # Debug log

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()
		print("Dragging part to:", global_position)  # Debug log

# Detect mouse button release globally
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragging:
			dragging = false
			snap_to_nearest_connection()
			print("Stopped dragging at:", global_position)  # Debug log

func snap_to_nearest_connection():
	var min_distance = 30  # Snap threshold
	var closest_point = null

	for other_part in get_parent().get_children():
		if other_part == self:
			continue
		for point in other_part.get_node_or_null("ConnectionPoints").get_children():
			var distance = global_position.distance_to(point.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_point = point

	if closest_point:
		global_position = closest_point.global_position
		print("Snapped to:", closest_point.global_position)  # Debug log
