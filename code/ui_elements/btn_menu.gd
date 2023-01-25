extends Button


@export var is_blur_dis = false
@export var is_focus_imm = false


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
	if is_focus_imm: return
	$InnerStrokeFocus.visible = false
	$OuterStrokeFocus.visible = false
