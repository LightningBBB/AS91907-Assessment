extends Node

@export var anomaly_1: PackedScene
@export var anomaly_2: PackedScene
@export var anomaly_3: PackedScene

@onready var tilemap = $"../NavigationRegion2D/Location"
@onready var enemies = $"../Enemies"

var spawn_tiles := {}

var spawn_rules = {
	"A0": {"allowed": [], "ratio": 0.0},
	"A1": {"allowed": [], "ratio": 0.0},
	"B1": {"allowed": ["anomaly_1"], "ratio": 0.0017},
	"B2": {"allowed": ["anomaly_1", "anomaly_2"], "ratio": 0.0034},
	"C0": {"allowed": ["anomaly_2"], "ratio": 0.0025},
	"D0": {"allowed": ["anomaly_3"], "ratio": 0.0068},
	"GΩ": {"allowed": ["anomaly_1", "anomaly_2", "anomaly_3"], "ratio": 0.01}
}

var region_quotas = {}


func _ready() -> void:
	get_spawn_tiles()
	calculate_quotas()
	spawn()


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
		pos += Vector2(tilemap.tile_set.tile_size) * tilemap.scale / 2.0

		if not spawn_tiles.has(region):
			spawn_tiles[region] = []

		spawn_tiles[region].append(tilemap.to_global(pos))


func calculate_quotas() -> void:
	for region in spawn_tiles:
		var count = spawn_tiles[region].size()
		var rule = spawn_rules[region]
		if rule["allowed"].is_empty():
			continue
		region_quotas[region] = int(count * rule["ratio"])


func spawn() -> void:
	var total_spawns = 0
	for q in region_quotas.values():
		total_spawns += q

	var spawned = 0

	for region in spawn_tiles:
		if not region_quotas.has(region):
			continue

		var quota = region_quotas[region]
		if quota <= 0:
			continue

		var allowed = spawn_rules[region]["allowed"]
		var tiles = spawn_tiles[region].duplicate()
		tiles.shuffle()

		for pos in tiles:
			if quota <= 0:
				break

			var type = allowed.pick_random()
			var scene: PackedScene = null
			match type:
				"anomaly_1": scene = anomaly_1
				"anomaly_2": scene = anomaly_2
				"anomaly_3": scene = anomaly_3

			if scene == null:
				continue

			var enemy = scene.instantiate()
			enemy.global_position = pos
			enemies.add_child(enemy)

			quota -= 1
			spawned += 1

		region_quotas[region] = quota
