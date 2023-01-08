extends Spatial


func _on_Trigger_body_entered(body): 
	if body.has_method("jump"): 
		body.jump(1.5, true)
