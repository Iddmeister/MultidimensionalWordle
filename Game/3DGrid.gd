extends Spatial

export var speed:float = 0.2
export var zspacing:float = 4
export var xspacing:float = 0

onready var move:Tween = get_parent().get_node("Move")

func _ready():
	
	for b in range(get_child_count()):
		
		var board:Spatial = get_child(b)
		
		board.transform.origin.z = (b-2)*zspacing
		board.transform.origin.x = (b-2)*-xspacing
		board.texture = board.get_node("Viewport").get_texture()
		var area:Area = board.get_node("Area")
		area.connect("input_event", self, "boardEvent", [board])
		
	pass
	
func boardEvent(cam, event, pos, normal, index, board:Sprite3D):
	if event is InputEventMouseButton and event.is_action("pan"):
		if event.is_pressed():
			var p = get_parent().get_node("Pivot")
			move.interpolate_property(p, "transform:origin:x", null, board.transform.origin.x, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			move.interpolate_property(p, "transform:origin:z", null, board.transform.origin.z, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			move.start()
	pass
	
	
func changeLayout(x:float, z:float):
	
	for b in range(get_child_count()):
		
		var board:Spatial = get_child(b)
		
		move.interpolate_property(board, "transform:origin:z", null, (b-2)*z, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		move.interpolate_property(board, "transform:origin:x", null, (b-2)*-x, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		move.start()
		
		pass
	
	pass


func _on_xspacing_value_changed(value):
	xspacing = value
	changeLayout(xspacing, zspacing)


func _on_zspacing_value_changed(value):
	zspacing = value
	changeLayout(xspacing, zspacing)


func _on_CheckBox_toggled(button_pressed):
	get_tree().set_group("Board", "billboard", button_pressed)
