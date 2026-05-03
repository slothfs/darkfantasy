extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color.a = 1.0
	# Make sure the fade node is above everything else
	layer = 100
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	fade(0.0, 0.5)

func fade(target_alpha: float, duration: float = 1.0) -> Tween:
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween

func transition_to_scene(path: String, duration: float = 0.5) -> void:
	# Ignore mouse clicks during transition
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw = fade(1.0, duration)
	await tw.finished
	get_tree().change_scene_to_file(path)
	tw = fade(0.0, duration)
	await tw.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
