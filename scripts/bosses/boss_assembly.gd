extends Node2D

# Preload part scenes
var CoreScene = preload("res://scenes/bosses/Core.tscn")
var ArmScene = preload("res://scenes/bosses/Arm.tscn")
var ElbowScene = preload("res://scenes/bosses/Elbow.tscn")

func _ready():
	generate_boss(Vector2(640, 360))  # Adjust as needed

func generate_boss(position: Vector2):
	# Instantiate Core
	var core = CoreScene.instantiate()
	core.position = position
	add_child(core)

	# Debug: Print core connection point positions
	var connection_points = core.get_node("ConnectionPoints").get_children()
	for connection in connection_points:
		print("Core Connection Point at: ", connection.global_position)

	# Attach one Elbow to a random connection point on the Core
	if connection_points.size() > 0:
		var random_connection = connection_points[randi() % connection_points.size()]
		var elbow = ElbowScene.instantiate()

		# Align elbow's first connection point with the core's connection point
		var elbow_connection = elbow.get_node("ConnectionPoints").get_children()[0]
		var offset = elbow_connection.position

		# Convert global position to local relative to BossAssembler
		elbow.position = to_local(random_connection.global_position) - offset
		align_part(elbow, random_connection)
		add_child(elbow)

		# Debug: Print elbow connection point positions
		for elbow_cp in elbow.get_node("ConnectionPoints").get_children():
			print("Elbow Connection Point at: ", elbow_cp.global_position)

		# Attach one Arm to the other connection point on the Elbow
		var elbow_connections = elbow.get_node("ConnectionPoints").get_children()
		if elbow_connections.size() > 1:
			for connection in elbow_connections:
				if connection != elbow_connection:
					var arm = ArmScene.instantiate()

					# Align arm's first connection point with the elbow's other connection point
					var arm_connection = arm.get_node("ConnectionPoints").get_children()[0]
					var arm_offset = arm_connection.position

					# Convert global position to local relative to BossAssembler
					arm.position = to_local(connection.global_position) - arm_offset
					align_part(arm, connection)
					add_child(arm)

					# Debug: Print arm connection point positions
					for arm_cp in arm.get_node("ConnectionPoints").get_children():
						print("Arm Connection Point at: ", arm_cp.global_position)

					break

# Align part rotation to match connection point orientation
func align_part(part, connection_point):
	var direction = (connection_point.global_position - part.global_position).normalized()
	part.rotation = direction.angle()
