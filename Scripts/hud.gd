extends CanvasLayer

@onready var fuel_bar = $Control/ProgressBar

func _process(_delta):
	fuel_bar.value = Global.fuel
