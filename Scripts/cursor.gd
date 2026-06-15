extends Node2D

@onready var sprite = $Sprite2D

var cursors = {
	"pointer": preload("res://Assets/Cursors/pointer.png"),
	"scan": preload("res://Assets/Cursors/scan.png")
}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	

func _process(_delta: float) -> void:
	if Global.cursor == "pointer":
		set_cursor("pointer")
	elif Global.cursor == "scan":
		set_cursor("scan")
	position = get_global_mouse_position()

func set_cursor(name: String):
	if cursors.has(name):
		sprite.texture = cursors[name]
	else:
		print("Texture not found")
