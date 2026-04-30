class_name World
extends Node2D

@export var obstacle_layer:int
@export var tilemap:TileMap

var tile_size:int
var size:Vector2i
var cells:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if not tilemap:
		tilemap = $TileMap
	tile_size = tilemap.rendering_quadrant_size
	size = get_viewport_rect().size / tile_size
	print("world has " + str(size.y) + " rows and " + str(size.x) + " cols")
	initialize_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)

## Creates a 2D array that represents a discrete world.
## We build this programmatically from a TileMap so that it is easy to design
## the world in th Godot editor by simply placing tiles appropriately.
func initialize_grid():
	cells.resize(size.x)
	for dx in range(0, size.x):
		cells[dx] = []
		cells[dx].resize(size.y)
		for dy in range(0, size.y):
			var s = tilemap.get_cell_source_id(obstacle_layer, Vector2i(dx, dy))
			var is_obstacle = s != -1
			cells[dx][dy] = is_obstacle

func neighbors(cell:Vector2i):
	var ns = []
	if cell.x > 0 and cells[cell.x - 1][cell.y] == false:
		ns.append(Vector2i(cell.x - 1, cell.y))
	if cell.x < size.x - 1 and cells[cell.x + 1][cell.y] == false:
		ns.append(Vector2i(cell.x + 1, cell.y))
	if cell.y > 0 and cells[cell.x][cell.y - 1] == false:
		ns.append(Vector2i(cell.x, cell.y - 1))
	if cell.y < size.y - 1 and cells[cell.x][cell.y + 1] == false:
		ns.append(Vector2i(cell.x, cell.y + 1))
	return ns

func cost(src:Vector2i, dst:Vector2i):
	if cells[dst.x][dst.y]:
		return 1000 #INF
	elif abs(dst.x - src.x) > 1 or abs(dst.y - src.y) > 1:
		return 1000 #INF
	else:
		return 1
