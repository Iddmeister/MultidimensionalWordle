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
