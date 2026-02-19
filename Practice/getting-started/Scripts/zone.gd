class_name Zone
extends Node2D
## Reprenesnts a circular region of space that can detect whether "spot"
## is inside or outside, and respnd accordingly.

# Import another script into this one
const PointTest = preload("res://Scripts/point_test.gd")

##Location of the center of the zone
@export var center:Vector2 = Vector2.ZERO
## Size of the zone from center to edge
@export var radius:float = 5.0
## Initial color of the zone
@export var color:Color = Color.CYAN

## Called when CanvasItem has been requested to redraw
func _draw() -> void:
	draw_circle(center, radius, color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PointTest.on_circle($"../Spot".center, center, radius) <= 0:
		color.a = 0.5
	else:
		color.a = 1
	queue_redraw()
