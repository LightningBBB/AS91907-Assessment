extends Control

@export var type_speed: float = 0.04

const LABELS = ["EXPEDITION", "ENDLESS", "SETTINGS", "QUIT"]

@onready var buttons = [
	$TitleContainer/Expedition,
	$TitleContainer/Endless,
	$TitleContainer/Settings,
	$TitleContainer/Quit
]

var focused := -1
var typing := true

func _ready() -> void:
	for btn in buttons:
		btn.text = ""
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.mouse_entered.connect(_on_hover.bind(buttons.find(btn)))
	_type_all()

func _type_all() -> void:
	for i in buttons.size():
		await _type(buttons[i], LABELS[i])
		await get_tree().create_timer(0.15).timeout
	typing = false

func _type(btn: Button, text: String) -> void:
	for c in text:
		btn.text += c
		await get_tree().create_timer(type_speed).timeout

func _on_hover(i: int) -> void:
	if typing:
		return
	if focused >= 0:
		buttons[focused].text = LABELS[focused]
	focused = i
	buttons[i].text = "> " + LABELS[i]

func _on_expedition_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/expedition.tscn")

func _on_endless_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/endless.tscn")
