@tool
extends SpotLight3D
@export var look_target:Node3D
var disabled = false
var place = 0
@onready var mesh = $"../P1Light/MeshInstance3D"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mesh:
		var mesh:SphereMesh = mesh.mesh
		var material:StandardMaterial3D = mesh.surface_get_material(0)
		material.emission_energy_multiplier = light_energy
	if disabled:
		return
	place += delta
	light_energy = randf_range(0.6,1.0) * 3
	if not look_target:
		return
	look_at(look_target.global_position)
	pass
