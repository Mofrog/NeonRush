extends Button


@export var is_blur_dis = false


func _ready():
	if is_blur_dis:
		$Panel.visible = false
	if disabled:
		$InnerStrokeFocus.visible = false
		$OuterStrokeFocus.visible = false
		$InnerStroke.visible = false
		$OuterStroke.visible = false
		$InnerStrokeDis.visible = true
		$OuterStrokeDis.visible = true


func _on_focus_entered():
	$InnerStrokeFocus.visible = true
	$OuterStrokeFocus.visible = true


func _on_focus_exited():
	$InnerStrokeFocus.visible = false
	$OuterStrokeFocus.visible = false
