extends Button


func _on_focus_entered():
	$InnerStrokeFocus.visible = true
	$OuterStrokeFocus.visible = true


func _on_focus_exited():
	$InnerStrokeFocus.visible = false
	$OuterStrokeFocus.visible = false
