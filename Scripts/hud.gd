extends CanvasLayer

@onready var fuel_bar = $Control/FuelTank/Fuel
@onready var fuel_bonus_bar = $Control/FuelTank/FuelBonus
@onready var prototype_goal = $Control/PrototypeGoal
@onready var death_label = $Control/Death


func _process(_delta):
	fuel_bar.value = Global.fuel
	fuel_bonus_bar.value = Global.fuelbonus
	if Global.fuel == 0:
		death_label.show()

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	
	prototype_goal.hide() 
