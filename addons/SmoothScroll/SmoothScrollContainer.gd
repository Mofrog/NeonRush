## Smooth scroll functionality for ScrollContainer
##
## Applies velocity based momentum and "overdrag"
## functionality to a ScrollContainer
extends ScrollContainer


# Drag impact for one scroll input
@export var speed = 2.0
# Softness of damping when "overdragging"
@export var damping = 0.1
@export var shadows = Control.new()

# Current velocity of the `content_node`
var velocity := Vector2(0,0)
# Below this value, velocity is set to `0`
var just_stop_under := 0.01
# Current counterforce for "overdragging" on the top
var over_drag_multiplicator_top := 1
# Current counterforce for "overdragging" on the bottom
var over_drag_multiplicator_bottom := 1
# Control node to move when scrolling
var content_node : Control
# Current position of `content_node`
var pos := Vector2(0, 0)
# When true, `content_node`'s position is only set by dragging the scroll bar
var scrolling := false
var lft_mouse_pressed = false


func _ready() -> void:
	get_v_scroll_bar().scrolling.connect(_on_VScrollBar_scrolling)
	get_v_scroll_bar().custom_minimum_size = Vector2(10, 0)
	for c in get_children():
		content_node = c


func _process(_delta: float) -> void:
	
	# If no scroll needed, don't apply forces
	if content_node.size.y - self.size.y < 1: 
		return
	
	# Distance between content_node's bottom and bottom of the scroll box 
	var bottom_distance = content_node.position.y + content_node.size.y - self.size.y
	# Distance between content_node and top of the scroll box
	var top_distance = content_node.position.y
	
	# If overdragged on bottom:
	if bottom_distance < 0 :
		over_drag_multiplicator_bottom = (1 / abs(bottom_distance) * 10)
		if shadows != null: shadows.get_child(1).visible = false
	elif bottom_distance < 10:
		if shadows != null: shadows.get_child(1).visible = false
	else:
		over_drag_multiplicator_bottom = 1
		if shadows != null: shadows.get_child(1).visible = true
	
	# If overdragged on top:
	if top_distance > 0:
		over_drag_multiplicator_top = (1 / abs(top_distance) * 10)
		if shadows != null: shadows.get_child(0).visible = false
	elif top_distance > -10:
		if shadows != null: shadows.get_child(0).visible = false
	else:
		over_drag_multiplicator_top = 1
		if shadows != null: shadows.get_child(0).visible = true
	
	# Simulate friction
	velocity *= 0.9
	
	# If velocity is too low, just set it to 0
	if velocity.length() <= just_stop_under:
		velocity = Vector2(0,0)
	
	# Applies counterforces when overdragging
	if bottom_distance< 0 :
		velocity.y = lerp(velocity.y, -bottom_distance/8, damping)
	if top_distance> 0:
		velocity.y = lerp(velocity.y, -top_distance/8, damping)
	
	# If using scroll bar dragging, set the content_node's
	# position by using the scrollbar position
	if scrolling:
		pos = content_node.position
		return
	
	# Move content node by applying velocity
	pos += velocity
	content_node.position = pos
	
	# Update vertical scroll bar
	set_v_scroll(-pos.y)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			5: 
				velocity.y -= speed
				lft_mouse_pressed = false
			4: 
				velocity.y += speed
				lft_mouse_pressed = false
			1: lft_mouse_pressed = true
		
		if not event.pressed: 
			scrolling = false
			lft_mouse_pressed = false
	
	if event is InputEventMouseMotion && lft_mouse_pressed:
		velocity.y = (event.velocity.y / 200) * speed


func _on_VScrollBar_scrolling() -> void:
	scrolling = true


# Scrolls up a page
func scroll_page_up() -> void:
	velocity.y += (size.y / 10)


# Scrolls down a page
func scroll_page_down() -> void:
	velocity.y -= (size.y / 10)


# Adds velocity to the vertical scroll
func scroll_vertical(amount: float) -> void:
	velocity.y -= amount

# Scrolls to top
func scroll_to_top() -> void:
	# Reset velocity
	velocity.y = 0
	# Move content node to top
	pos.y = 0
	content_node.position = pos
	# Update vertical scroll bar
	set_v_scroll(-pos.y)


# Scrolls to bottom
func scroll_to_bottom() -> void:
	# Reset velocity
	velocity.y = 0
	# Move content node to bottom
	pos.y = -content_node.size.y + size.y
	content_node.position = pos
	# Update vertical scroll bar
	set_v_scroll(-pos.y)
