extends CanvasLayer

@onready var fuel_bar = $Control/FuelTank/Fuel
@onready var fuel_bonus_bar = $Control/FuelTank/FuelBonus
@onready var objective_label = $Control/Objective
@onready var death_label = $Control/Death
@onready var location_label = $Control/Location

var location = "nowhere"


func _process(_delta):
	fuel_bar.value = Global.fuel
	fuel_bonus_bar.value = Global.fuelbonus

	if Global.fuel == 0:
		death_label.show()

	location_label.text = location


func _ready() -> void:
	get_parent().location_entered.connect(_on_location_entered)
	
	await get_tree().create_timer(3.0).timeout
	objective_label.hide()


func _on_location_entered(entered_location):
	var loc_words = entered_location.split("_")

	for i in range(loc_words.size()):
		loc_words[i] = loc_words[i].capitalize()

	location = " ".join(loc_words)
