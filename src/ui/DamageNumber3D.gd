extends Node3D

@onready var _label: Label3D = $Label3D


func setup(amount: int) -> void:
	if _label:
		_label.text = str(amount)
	_animate()


func _animate() -> void:
	# Random horizontal jitter for visual variety
	var jitter := Vector3(randf_range(-0.2, 0.2), 0.0, randf_range(-0.2, 0.2))
	var target_position := position + Vector3(0, 1.5, 0) + jitter
	var duration := randf_range(0.6, 0.9)

	var tween := create_tween()
	tween.set_parallel(true)

	# Move upward with jitter
	tween.tween_property(self, "position", target_position, duration).set_ease(Tween.EASE_OUT)

	# Fade out the label
	if _label:
		tween.tween_property(_label, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)

	# Free when done
	tween.chain().tween_callback(queue_free)
