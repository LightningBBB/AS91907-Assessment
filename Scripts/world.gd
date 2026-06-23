extends Node2D

func _ready() -> void:
	$Void.show()

	$NavigationRegion2D/Location.hide()
	$TileMapLayer.hide()

	Global.cursor = "scan"
