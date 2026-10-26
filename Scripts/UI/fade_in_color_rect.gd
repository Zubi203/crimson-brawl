class_name FadeInColorRect
extends ColorRect

@export var ignore_time_scale: bool = true
@export var fade_in_duration: float = 0.5
@export_range(0, 1.0, 0.01) var target_transparency: float = 0.0
@export_range(0, 1.0, 0.01) var start_transparency: float = 1.0

func _ready() -> void:
	var tween = create_tween()
	tween.set_ignore_time_scale(ignore_time_scale)
	tween.tween_property(self, "modulate:a", target_transparency, fade_in_duration).from(start_transparency)
