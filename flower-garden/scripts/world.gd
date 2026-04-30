class_name World
extends Node2D
## Representation of a simple grid-based world.

## Reference to the tile-map layer containing the obstacles in this world.
@export var obstacles:TileMapLayer

## Internal Boolean representation of the obstacle grid for this world.
var cells:Array[bool] = []
## Dimensions of the world in discrete tile coordinates.
var size:Vector2i
## Size in pixels of each square tile in the world.
var tile_size:int


## Return the cost of moving from a source cell to a destination cell
## This represents direct edges in the "graph" so only immediately adjacent
## cells have a finite cost. For now, if the destination is immediately adjacent
## to the source and it is not an obstacle, then assign a cost of 1, otherwise
## assign it an infinite cost (see built-in INF constant).
func cost(src:Vector2i, dst:Vector2i) -> float:
	if cells[size.x * dst.y + dst.x]:
		return INF
	elif (dst - src).length_squared() != 1:
		return INF
	else:
		return 1


## Creates a 2D array that represents a discrete world.
## We build this programmatically from the TileMapLayer so that it is easy to
## design the world in the Godot editor by simply placing tiles appropriately.
func initialize_grid() -> void:
	cells.resize(size.x * size.y)
	for dx in range(0, size.x):
		for dy in range(0, size.y):
			cells[size.x * dy + dx] = obstacles.get_cell_source_id(Vector2i(dx, dy)) != -1


## Returns the coordinates of the immediate neighbors for the specified cell.
func neighbors(cell:Vector2i) -> Array[Vector2i]:
	var ns:Array[Vector2i] = []
	if cell.x > 0 and cells[size.x * cell.y + cell.x - 1] == false:
		ns.append(Vector2i(cell.x - 1, cell.y))
	if cell.x < size.x - 1 and cells[size.x * cell.y + cell.x + 1] == false:
		ns.append(Vector2i(cell.x + 1, cell.y))
	if cell.y > 0 and cells[size.x * (cell.y - 1) + cell.x] == false:
		ns.append(Vector2i(cell.x, cell.y - 1))
	if cell.y < size.y - 1 and cells[size.x * (cell.y + 1) + cell.x] == false:
		ns.append(Vector2i(cell.x, cell.y + 1))
	return ns


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not obstacles:
		obstacles = $Obstacles
	tile_size = obstacles.rendering_quadrant_size
	size = get_viewport_rect().size / tile_size
	print("world has " + str(size.y) + " rows and " + str(size.x) + " cols")
	initialize_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void: pass
