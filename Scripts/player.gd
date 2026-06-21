extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const SHIFT_SPEED = -100

@onready var interaction_area = $Area2D 
@onready var hud = $Hud
@onready var location_tilemap = $"../Location"

var last_tile := Vector2i(-1, -1)

signal location_entered(location: String)


func _ready() -> void:
	randomize()
	
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()

	if not Input.is_action_pressed("sneak"):
		velocity.x = SPEED * direction.x
		velocity.y = SPEED * direction.y
	else:
		velocity.x = (SPEED + SHIFT_SPEED) * direction.x
		velocity.y = (SPEED + SHIFT_SPEED) * direction.y

	move_and_slide()

	# damage handling
	var touching_bodies = interaction_area.get_overlapping_bodies()
	for body in touching_bodies:
		if body.get_meta("creature") == "anomaly_1":
			if Global.fuel > 0:
				Global.fuel -= 1	

	# Location Test
	var tile: Vector2i = location_tilemap.local_to_map(location_tilemap.to_local(global_position))

	if tile == last_tile:
		return

	last_tile = tile

	var data: TileData = location_tilemap.get_cell_tile_data(tile)
	if data == null:
		return

	var location: String = data.get_custom_data("location")
	if location == "":
		return

	location_entered.emit(location)
