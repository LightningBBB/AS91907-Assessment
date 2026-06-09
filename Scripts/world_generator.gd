extends Node2D

@export var tilemap: TileMapLayer

@export var source_id: int = 0
@export var wall_atlas_coord := Vector2i(0, 0)
@export var floor_atlas_coord := Vector2i(1, 0)
@export var use_floor_tile: bool = false  # false = floors are just empty cells

@export var width: int = 512
@export var height: int = 512
@export var fill_percent: float = 0.40
@export var smooth_passes: int = 6
@export var use_random_seed: bool = true
@export var manual_seed: int = 0

var grid: Array = []

func _ready() -> void:
	generate()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		generate()

func generate() -> void:
	var rng_seed := manual_seed
	if use_random_seed:
		rng_seed = randi()
	seed(rng_seed)
	print("Cave seed: ", rng_seed)

	_init_grid()
	for _i in smooth_passes:
		_smooth_pass()
	_render()


func _init_grid() -> void:
	grid = []
	for x in width:
		grid.append([])
		for y in height:
			var border := (x == 0 or x == width - 1 or y == 0 or y == height - 1)
			grid[x].append(border or randf() < fill_percent)


func _smooth_pass() -> void:
	var next: Array = []
	for x in width:
		next.append([])
		for y in height:
			var walls := _neighbour_wall_count(x, y)
			if walls > 4:
				next[x].append(true)
			elif walls < 4:
				next[x].append(false)
			else:
				next[x].append(grid[x][y])
	grid = next

func _neighbour_wall_count(cx: int, cy: int) -> int:
	var count := 0
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx := cx + dx
			var ny := cy + dy
			if nx < 0 or nx >= width or ny < 0 or ny >= height:
				count += 1
			elif grid[nx][ny]:
				count += 1
	return count


func _render() -> void:
	tilemap.clear()
	for x in width:
		for y in height:
			var cell := Vector2i(x, y)
			if grid[x][y]:
				tilemap.set_cell(cell, source_id, wall_atlas_coord)
			elif use_floor_tile:
				tilemap.set_cell(cell, source_id, floor_atlas_coord)
