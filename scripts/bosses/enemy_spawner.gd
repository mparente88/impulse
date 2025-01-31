extends Node2D

@export var CoreScene: PackedScene
@export var ArmScene: PackedScene
@export var ElbowScene: PackedScene

func _ready():
	assemble_enemy()

func assemble_enemy():
	var enemy = Node2D.new()
	add_child(enemy)

	# Spawn Core
	var core = CoreScene.instantiate()
	enemy.add_child(core)
	core.position = Vector2(0, 0)  # Core starts at the enemy origin
	print("Spawned Core at ", core.global_position)

	# Store available connection points
	var available_points = []
	print("Checking available connection points:")
	for i in range(1, 9):  # Assuming 8 connection points
		var connection_point = core.get_node_or_null("ConnectionPoint" + str(i))
		if connection_point:
			available_points.append(connection_point)
			print(" - Found: ConnectionPoint" + str(i), " at ", connection_point.global_position)
		else:
			print(" - ERROR: ConnectionPoint" + str(i) + " not found on Core!")

	# Randomly determine number of arms
	var num_arms = randi_range(2, 5)  # Adjust range for more/less arms
	print("Spawning", num_arms, "arms")

	for i in range(num_arms):
		if available_points.is_empty():
			print("No available connection points left!")
			break

		# Pick a random available connection point
		var point_index = randi() % available_points.size()
		var chosen_point = available_points.pop_at(point_index)

		# Attach Arm
		var arm = ArmScene.instantiate()
		chosen_point.add_child(arm)  # Attach arm as a child of connection point
		arm.position = Vector2.ZERO  # Keep it local to the attachment point
		arm.rotation = chosen_point.global_rotation  # Fix rotation
		print("Attached Arm at ", arm.global_position, " with rotation ", arm.global_rotation)

		# Debug draw line from core to arm
		draw_debug_line(chosen_point.global_position, arm.global_position, Color(1, 0, 0))

		# Attach Elbow (random chance)
		if randi_range(0, 1) == 1:
			var elbow = ElbowScene.instantiate()
			var elbow_point = arm.get_node_or_null("ConnectionPoint1")  # Attach elbow at end of arm
			if elbow_point:
				elbow_point.add_child(elbow)  # Attach elbow as a child
				elbow.position = Vector2.ZERO  # Keep it local to the attachment point
				elbow.rotation = elbow_point.global_rotation  # Fix rotation
				print("Attached Elbow at ", elbow.global_position, " with rotation ", elbow.global_rotation)

				# Debug line from arm to elbow
				print("Drawing line from Arm to Elbow: ", arm.global_position, " to ", elbow.global_position)
				draw_debug_line(arm.global_position, elbow.global_position, Color(0, 1, 0))

				# (Optional) Attach another arm to the elbow
				if randi_range(0, 1) == 1:
					var extra_arm = ArmScene.instantiate()
					var extra_point = elbow.get_node_or_null("ConnectionPoint2")
					if extra_point:
						extra_point.add_child(extra_arm)  # Attach extra arm
						extra_arm.position = Vector2.ZERO
						extra_arm.rotation = extra_point.global_rotation
						print("Attached Extra Arm at ", extra_arm.global_position, " with rotation ", extra_arm.global_rotation)

						# Debug line from elbow to extra arm
						draw_debug_line(elbow.global_position, extra_arm.global_position, Color(0, 0, 1))
					else:
						print("ERROR: ConnectionPoint2 not found on Elbow!")
			else:
				print("ERROR: ConnectionPoint1 not found on Arm!")

	return enemy


# Debug helper to draw lines between connections
func draw_debug_line(start_pos: Vector2, end_pos: Vector2, color: Color):
	print("Drawing debug line from", start_pos, "to", end_pos)
	var line = Line2D.new()
	line.default_color = color
	line.width = 2
	line.add_point(start_pos)
	line.add_point(end_pos)
	add_child(line)
