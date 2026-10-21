class_name AIInputHandler
extends InputHandler

var brain: AIBrain

func _ready() -> void:
	for child in owner.get_children():
		if child is AIBrain:
			brain = child

func get_input_packet() -> InputPacket:
	var packet = InputPacket.new()
	
	if brain == null:
		return packet
	
	packet.inputs = brain.decide_inputs()
	return packet
