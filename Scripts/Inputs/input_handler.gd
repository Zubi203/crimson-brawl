class_name InputHandler
extends Node

var fighter: Fighter

func _ready() -> void:
	if owner is Fighter:
		fighter = owner

func get_input_packet() -> InputPacket:
	return null
