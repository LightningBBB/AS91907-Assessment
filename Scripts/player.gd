extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0
const SHIFT_SPEED: float = -100.0

@onready var interaction_area = $Area2D
@onready var hud = $Hud
@onready var location_tilemap = $"../NavigationRegion2D/Location"

var current_feeder_node: Area2D = null
var last_tile := Vector2i(-1, -1)
var near_feeder_node := "none"
var interact_hold_time = 2.0
var held_time = 0.0

signal location_entered(location: String, cell: Vector2i)


func _ready() -> void:
	randomize()
	queue_redraw()


# Movement
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()

	if not Input.is_action_pressed("sneak"):
		velocity.x = SPEED * direction.x
		velocity.y = SPEED * direction.y
	else:
		velocity.x = (SPEED + SHIFT_SPEED) * direction.x
		velocity.y = (SPEED + SHIFT_SPEED) * direction.y

	move_and_slide()

	# Anomaly interaction
	var touching_bodies = interaction_area.get_overlapping_bodies()
	for body in touching_bodies:
		if body.has_meta("creature") and body.get_meta("creature") == "anomaly_1":
			if Global.fuel > 0:
				Global.fuel -= 1

	# Eco transmitter interaction
	if Input.is_action_pressed("interact") and near_feeder_node != "none":
		held_time += delta

		if held_time >= interact_hold_time:
			held_time = 0.0

			if current_feeder_node:
				print("working")
				current_feeder_node.get_parent().status = true
	else:
		held_time = 0.0

	# Tile region detection
	var tile: Vector2i = location_tilemap.local_to_map(
		location_tilemap.to_local(global_position)
	)

	if tile == last_tile:
		return

	last_tile = tile

	var data: TileData = location_tilemap.get_cell_tile_data(tile)
	if data == null:
		return

	var location: Variant = data.get_custom_data("region")
	if location == null:
		return

	location_entered.emit(str(location), tile)


# Area enter
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_meta("type") == "feeder_node":
		current_feeder_node = area
		near_feeder_node = str(area.get_parent().get_meta("region"))


# Area exit
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_meta("type") == "feeder_node":
		if current_feeder_node == area:
			current_feeder_node = null

		near_feeder_node = "none"
