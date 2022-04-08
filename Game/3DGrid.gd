extends Spatial

export var speed:float = 0.2
export var zspacing:float = 4
export var xspacing:float = 5.7

export var singleView:bool = true
export var automaticViewSwitch:bool = true

onready var move:Tween = get_parent().get_node("Move")

onready var selectedBoard:Spatial = get_child(6)

onready var aspect:Vector2 = OS.window_size/OS.window_size.x

signal selectedLine(grid, line)

func _ready():
	get_tree().root.connect("size_changed", self, "resized")
	
	if automaticViewSwitch:
		
		if (aspect.y < 2) and OS.window_size.x >= 1000:
			singleView = false
		else:
			singleView = true
	
		OS.window_size = Vector2(600, 600) if singleView else Vector2(1000, 600)
	
	setView(singleView, true)
		
	selectedBoard.get_node("Viewport/Grid").selectLine(0)
	selectedBoard.get_node("Back").modulate = selectedBoard.get_node("Viewport/Grid").selectedColor
	
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
	
	
func resized():
	aspect = OS.window_size/OS.window_size.x
	if (aspect.y < aspect.x) and OS.window_size.x >= 1000:
		singleView = false
	else:
		singleView = true
	setView(singleView, false)
	
	
var panning:bool = false
	
func boardEvent(cam, event, pos, normal, index, board:Sprite3D):
	if (event is InputEventScreenTouch or (event is InputEventMouseButton and event.is_action("click"))) and event.pressed:
		
		
		if board.name == "Answer" and not singleView:
			return
		
		if not board == selectedBoard:
			
			selectedBoard = board
			
			if singleView:
				cycleBoards()
		
		for b in get_children():
			b.get_node("Back").modulate = Color(0.058824, 0.058824, 0.058824)
		
		selectedBoard.get_node("Back").modulate = selectedBoard.get_node("Viewport/Grid").selectedColor
		
		var offset = max(min(int(((selectedBoard.get_node("Area").transform.origin-pos).y)+3), 5), 0)
		
		if not selectedBoard.get_node("Viewport/Grid").complete and not selectedBoard.name == "Answer":
			selectedBoard.get_node("Viewport/Grid").selectLine(offset)
			emit_signal("selectedLine", selectedBoard.get_node("Viewport/Grid"), offset)
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

export var cycleSpeed:float = 0.2

func cycleBoards():
	
	var tween:Tween = get_parent().get_node("Move")
	
	var selected:int = selectedBoard.get_index()
	
	for b in range(get_child_count()):
		
		var board:Spatial = get_child(b)
		
		tween.interpolate_property(board, "transform:origin:z", null, abs(b-selected)*-zspacing, cycleSpeed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
		tween.interpolate_property(board, "transform:origin:x", null, (b-selected)*-xspacing, cycleSpeed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
		tween.start()
	
	pass

func setView(single:bool=false, first:bool=false):
	
	var selected:int = selectedBoard.get_index()
	
	for b in range(get_child_count()):
		
		var board:Spatial = get_child(b)
		
		if single:
			
			board.transform.origin.z = abs(b-selected)*-zspacing
			board.transform.origin.x = (b-selected)*-xspacing
			
		else:
			board.transform.origin.z = 0
			board.transform.origin.x = (b-3)*-xspacing
		
		if first:
			
			board.texture = board.get_node("Viewport").get_texture()
			var area:Area = board.get_node("Area")
			area.connect("input_event", self, "boardEvent", [board])
	
	
	pass
