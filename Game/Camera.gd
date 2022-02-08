extends Camera

export var x_sensitivity:float = 0.005
export var y_sensitivity:float = 0.003
export var zoom_amount:float = 5
export var zoom_speed:float = 0.2

var x_angle:float
var y_angle:float

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		
		if Input.is_action_pressed("pan"):
			
			y_angle = max(min(y_angle-event.relative.y*y_sensitivity, deg2rad(90)), deg2rad(-90))
			x_angle -= event.relative.x*x_sensitivity
			
			get_parent().rotation.x = y_angle
			get_parent().rotation.y = x_angle
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_WHEEL_UP:
			$Zoom.interpolate_property(self, "translation:z", null, translation.z-zoom_amount, zoom_speed, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
			$Zoom.start()
		elif event.button_index == BUTTON_WHEEL_DOWN:
			$Zoom.interpolate_property(self, "translation:z", null, translation.z+zoom_amount, zoom_speed, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
			$Zoom.start()

func _ready():
	pass
