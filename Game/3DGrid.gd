extends Spatial

export var speed:float = 0.2
export var zspacing:float = 4
export var xspacing:float = 0

onready var move:Tween = get_parent().get_node("Move")

onready var selectedBoard:Spatial = get_child(6)

func _ready():
	
	for b in range(get_child_count()):
		
		var board:Spatial = get_child(b)
		
		board.transform.origin.z = (b-2)*zspacing
		board.transform.origin.x = (b-2)*-xspacing
		board.texture = board.get_node("Viewport").get_texture()
		var area:Area = board.get_node("Area")
		area.connect("input_event", self, "boardEvent", [board])
		
		
	selectedBoard.get_node("Viewport/Grid").selectLine(0)
	
	moveCam(selectedBoard, true)
	selectedBoard.get_node("Back").get_active_material(0).albedo_color = selectedBoard.get_node("Viewport/Grid").selectedColor
	
func moveCam(board, rotate:bool=false):
	var p = get_parent().get_node("Pivot")
	move.interpolate_property(p, "transform:origin:x", null, board.transform.origin.x, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	move.interpolate_property(p, "transform:origin:z", null, board.transform.origin.z, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	if rotate:
		move.interpolate_property(p, "rotation:x", null, 0, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		move.interpolate_property(p, "rotation:y", null, 0, speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		p.get_child(0).x_angle = 0
		p.get_child(0).y_angle = 0
	move.start()
	
var panning:bool = false
	
func boardEvent(cam, event, pos, normal, index, board:Sprite3D):
	if event is InputEventMouseButton and event.is_action("click") and not panning and not event.pressed:
		
		selectedBoard = board
		
		for b in get_children():
			b.get_node("Back").get_active_material(0).albedo_color = Color(0.058824, 0.058824, 0.058824)
		
		selectedBoard.get_node("Back").get_active_material(0).albedo_color = selectedBoard.get_node("Viewport/Grid").selectedColor
		
		var offset = min(int(((selectedBoard.get_node("Area").transform.origin-pos).y)+3), 5)
		
		
		if not selectedBoard.get_node("Viewport/Grid").complete and not selectedBoard.name == "Answer":
			selectedBoard.get_node("Viewport/Grid").selectLine(offset)
		else:
			get_tree().call_group("Letter", "setBorder", Color(1, 1, 1, 1))
		
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

