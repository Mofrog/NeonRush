extends Panel
class_name Beat


func init(style : Theme, size : Vector2, position : Vector2):
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = style
	rect_size = size
	rect_position = position


func move(step : float): rect_position += Vector2(step, 0)
