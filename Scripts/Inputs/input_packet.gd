class_name InputPacket

var inputs: Dictionary[String, bool] = {
	"move_left" : false,
	"move_right" : false,
	"jump" : false,
	"dash" : false,
	"crouch" : false,
	"light_attack" : false,
	"heavy_attack" : false,
}

func is_pressed(input_string: String) -> bool:
	return inputs.get(input_string, false)
