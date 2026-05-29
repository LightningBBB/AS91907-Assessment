extends Node

@export var anomaly_1: PackedScene
@export var anomaly_1_spawns = 3
@export var anomaly_2: PackedScene
@export var anomaly_2_spawns = 10
@export var anomaly_3: PackedScene
@export var anomaly_3_spawns = 10

@onready var tilemap = $"../NavigationRegion2D/TileMapLayer"
@onready var enemies = $"../Enemies"

var spawn_tiles: Array[Vector2] = []

func _ready() -> void:
	get_spawn_tiles()
	spawn()

func get_spawn_tiles() -> void:
	for cell in tilemap.get_used_cells():
		var tile_data = tilemap.get_cell_tile_data(cell)
		
		if tile_data == null:
			continue
		
		var can_spawn = tile_data.get_custom_data("anomaly_1_spawn")
		
		if can_spawn == true:
			var pos = tilemap.map_to_local(cell)
			pos += Vector2(tilemap.tile_set.tile_size) / 2.0
			spawn_tiles.append(tilemap.to_global(pos))
		elif can_spawn == false:
			continue

func spawn() -> void:
	for i in anomaly_1_spawns:
		if spawn_tiles.is_empty():
			return
		
		var enemy = anomaly_1.instantiate()
		var spawn_pos = spawn_tiles.pick_random()
		
		enemy.global_position = spawn_pos
		enemies.add_child(enemy)
