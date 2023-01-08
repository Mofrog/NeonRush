# TODO Create a normal buttons

extends Control

signal pressed_group (button)

@export var buttons_count = 3
@export var selected = 0
@export var shortcuts # (Array, Shortcut)
@export var checked # (Array, Texture2D)
@export var unchecked # (Array, Texture2D)
@export var tooltip # (Array, String)

const BUTTON_WIDTH = 28
const BUTTON_HEIGHT = 30

var group = ButtonGroup.new()


func _ready():
	group.connect("pressed",Callable(self,"group_pressed"))
	minimum_size = Vector2(BUTTON_WIDTH * buttons_count, BUTTON_HEIGHT)
	
	for i in buttons_count:
		var button = CheckBox.new()
		button.group = group
		button.focus_mode = Control.FOCUS_NONE
		button.name = str(i)
		button.shortcut = shortcuts[i]
		button.tooltip_text = tooltip[i]
		if checked[i] != null: button.add_theme_icon_override("radio_checked", checked[i])
		if unchecked[i] != null: button.add_theme_icon_override("radio_unchecked", unchecked[i])
		$Background/Checkers.add_child(button)
		if selected == i: button.button_pressed = true


func _process(_delta):
	if selected != group.get_pressed_button().name.to_int():
		for i in group.get_buttons():
			if selected == i.name.to_int():
				i.button_pressed = true
				emit_signal("pressed_group", i.name.to_int())


func group_pressed(button): 
	selected = button.name.to_int()
	emit_signal("pressed_group", button.name.to_int())
