extends Label

class_name Letter

onready var panel:StyleBoxFlat = get_stylebox("normal")
onready var defaultColour:Color = panel.bg_color

enum {NORM, INCORRECT, MISPLACED, CORRECT}
var state:int = NORM

func setColour(color:Color):
	
	panel.bg_color = color
	
func setBorder(color:Color):
	
	panel.border_color = color

	
	
