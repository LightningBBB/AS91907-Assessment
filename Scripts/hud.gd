extends CanvasLayer

@onready var fuel_bar = $Control/FuelTank/Fuel
@onready var fuel_bonus_bar = $Control/FuelTank/FuelBonus
@onready var objective_label = $Control/Objective
@onready var death_label = $Control/Death
@onready var location_label = $Control/Location
@onready var actions = $Control/Actions
@onready var player = get_parent()
@onready var scanned: Node = get_tree().current_scene.get_node("Scanned")

var location_data = {
	"A0": "STABLE / EMPTY",
	"A1": "STABLE / INHABITED",
	"B1": "MODERATE / INHABITED",
	"B2": "HEAVY / INHABITED",
	"C0": "UNSTABLE / EMPTY",
	"D0": "UNSTABLE / HOSTILE",
	"GΩ": "UNKNOWN / ANOMALY"
}

var action_labels := {
	"scan": "SCAN [LMB]",
	"interact": "INTERACT [E]",
	"activate_feeder_node": "ACTIVATE FEEDER NODE [E]"
}

var active_actions := []
var location_display := "NOWHERE"


func _ready() -> void:
	show()

	get_parent().location_entered.connect(_on_location_entered)

	await get_tree().create_timer(3.0).timeout
	objective_label.hide()


func _process(_delta: float) -> void:
	fuel_bar.value = Global.fuel
	fuel_bonus_bar.value = Global.fuelbonus

	if Global.fuel == 0:
		death_label.show()

	location_label.text = location_display

	if player and player.near_feeder_node != "none":
		show_action("activate_feeder_node")
	else:
		hide_action("activate_feeder_node")


# Location updates
func _on_location_entered(entered_location: String, cell: Vector2i) -> void:
	var activated_region: String = scanned.get_region_at(cell)

	if activated_region == "":
		location_display = "NOWHERE"
		return

	var state = location_data.get(activated_region)
	if state == null:
		location_display = "TYPE [" + activated_region + "] REGION"
		return

	location_display = "TYPE [" + activated_region + "] REGION // STABILITY: " + state


# Action UI control
func show_action(key: String) -> void:
	if not action_labels.has(key):
		return

	if key not in active_actions:
		active_actions.append(key)

	_update_actions()


func hide_action(key: String) -> void:
	if key in active_actions:
		active_actions.erase(key)

	_update_actions()


func _update_actions() -> void:
	for child in actions.get_children():
		child.queue_free()

	for key in active_actions:
		var label := Label.new()
		label.text = action_labels[key]
		actions.add_child(label)
