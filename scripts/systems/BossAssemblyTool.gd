extends Control

var workspace
var CoreScene = preload("res://scenes/bosses/Core.tscn")
var ArmScene = preload("res://scenes/bosses/Arm.tscn")
var ElbowScene = preload("res://scenes/bosses/Elbow.tscn")

func _ready():
	workspace = get_node("Workspace")
	print("Boss Assembly Tool Ready")  # Debug log

func _on_Core_pressed():  # Match the signal function
	print("Core Button Pressed")  # Debug log
	spawn_part(CoreScene)

func _on_Arm_pressed():   # Match the signal function
	print("Arm Button Pressed")  # Debug log
	spawn_part(ArmScene)

func _on_Elbow_pressed(): # Match the signal function
	print("Elbow Button Pressed")  # Debug log
	spawn_part(ElbowScene)

func spawn_part(scene):
	print("Spawning Part: ", scene)  # Debug log
	var part_instance = scene.instantiate()
	part_instance.global_position = get_global_mouse_position()
	workspace.add_child(part_instance)
	print("Part Added to Workspace at: ", part_instance.global_position)  # Debug log
