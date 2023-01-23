extends Control


@export var items : PackedStringArray

@export var selected = 0.0
@export var max_value = 1.0
@export var min_value = 0.0
@export var step = 0.01
@export var btn_step = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	if items.size() > 0:
		for i in items:
			$Option.add_item(i)
		$Slider.max_value = items.size() - 1
		$Option.select(selected)
	else:
		$Option.visible = false
		$Line.visible = true
		$Slider.max_value = max_value
		$Slider.min_value = min_value
		$Slider.step = step
	$Slider.value = selected


func _on_r_button_pressed():
	if items.size() > 0:
		if items.size() > $Option.selected + 1:
			$Slider.value = $Option.selected + 1
	else:
		$Slider.value += btn_step


func _on_l_button_pressed():
	if items.size() > 0:
		if $Option.selected > 0:
			$Slider.value = $Option.selected - 1
	else:
		$Slider.value -= btn_step


func _on_slider_value_changed(value):
	if items.size() > 0: $Option.select(value)
	else: $Line.text = str(value)


func _on_option_item_selected(index):
	$Slider.value = index
