extends Node

@export var anomaly_1: PackedScene
@export var anomaly_1_spawns = 3
@export var anomaly_2: PackedScene
@export var anomaly_2_spawns = 0
@export var anomaly_3: PackedScene
@export var anomaly_3_spawns = 0

@onready var tilemap = $"../NavigationRegion2D/Location"
@onready var enemies = $"../Enemies"

var spawn_tiles := []

var spawn_rules = {
	"A0": [],
	"A1": ["anomaly_1"],
	"B1": ["anomaly_1", "anomaly_2"],
	"B2": ["anomaly_2"],
	"C0": ["anomaly_1", "anomaly_2", "anomaly_3"],
	"D0": ["anomaly_3"],
	"GΩ": ["anomaly_1", "anomaly_2", "anomaly_3"]
}


func _ready() -> void:
	get_spawn_tiles()
	spawn()


# gather valid spawn locations
func get_spawn_tiles() -> void:
	for cell in tilemap.get_used_cells():
		var tile_data = tilemap.get_cell_tile_data(cell)
		if tile_data == null:
			continue

		var region = tile_data.get_custom_data("region")
		if region == null:
			continue

		if not spawn_rules.has(region):
			continue

		var pos = tilemap.map_to_local(cell)
		pos += Vector2(tilemap.tile_set.tile_size) / 2.0

		spawn_tiles.append({
			"pos": tilemap.to_global(pos),
			"region": region
		})


# spawn anomalies
func spawn() -> void:
	var all_tiles = spawn_tiles.duplicate()
	all_tiles.shuffle()

	var total_spawns = anomaly_1_spawns + anomaly_2_spawns + anomaly_3_spawns
	var spawned = 0

	for tile in all_tiles:
		if spawned >= total_spawns:
			break

		var region = tile["region"]
		var pos = tile["pos"]

		var allowed = spawn_rules.get(region, [])
		if allowed.is_empty():
			continue

		var type = allowed.pick_random()

		var scene: PackedScene = null

		match type:
			"anomaly_1":
				if anomaly_1_spawns <= 0:
					continue
				scene = anomaly_1
				anomaly_1_spawns -= 1

			"anomaly_2":
				if anomaly_2_spawns <= 0:
					continue
				scene = anomaly_2
				anomaly_2_spawns -= 1

			"anomaly_3":
				if anomaly_3_spawns <= 0:
					continue
				scene = anomaly_3
				anomaly_3_spawns -= 1

		if scene == null:
			continue

		var enemy = scene.instantiate()
		enemy.global_position = pos
		enemies.add_child(enemy)

		spawned += 1
