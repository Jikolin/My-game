extends Area3D

signal move_to(dir: Vector3)
var dir: Vector3

func _ready():
	input_ray_pickable = true

func _input_event(_camera, event, _pos, _normal, _shape):
	if event is InputEventMouseButton and event.pressed:
		move_to.emit(dir)
