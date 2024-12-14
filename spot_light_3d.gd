@tool
extends SpotLight3D
@onready var mesh = $MeshInstance3D
@export var look_target:Node3D
var place = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	place += delta
	var actual_mesh:SphereMesh = mesh.mesh
	var material:StandardMaterial3D = actual_mesh.material
	light_energy = randf_range(0.6,1.0) * 2
	material.emission_energy_multiplier = light_energy * 1.5
	if not look_target:
		return
	look_at(look_target.global_position)
	pass
