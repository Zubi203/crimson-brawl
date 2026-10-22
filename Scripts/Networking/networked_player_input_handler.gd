class_name NetworkedPlayerInputHandler
extends PlayerInputHandler

@export var move_left: bool = false
@export var move_right: bool = false
@export var dash: bool = false
@export var jump: bool = false
@export var crouch: bool = false
@export var light_attack: bool = false
@export var heavy_attack: bool = false

func _ready() -> void:
	super._ready()
	
	for child in fighter.get_children():
		if child is InputSync:
			if child.get_multiplayer_authority() != NetworkManager.peer_id:
				set_physics_process(false)

func _physics_process(_delta: float) -> void:
	var packet: InputPacket = super.get_input_packet()
	move_left = packet.inputs["move_left"]
	move_right = packet.inputs["move_right"]
	dash = packet.inputs["dash"]
	jump = packet.inputs["jump"]
	crouch = packet.inputs["crouch"]
	light_attack = packet.inputs["light_attack"]
	heavy_attack = packet.inputs["heavy_attack"]

func get_input_packet() -> InputPacket:
	var packet: InputPacket = InputPacket.new()
	
	packet.inputs["move_left"] = move_left
	packet.inputs["move_right"] = move_right
	packet.inputs["dash"] = dash
	packet.inputs["jump"] = jump
	packet.inputs["crouch"] = crouch
	packet.inputs["light_attack"] = light_attack
	packet.inputs["heavy_attack"] = heavy_attack
	
	return packet
