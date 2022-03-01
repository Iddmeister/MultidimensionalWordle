extends Label

class_name Letter

onready var panel:StyleBoxFlat = get_stylebox("normal")

func setColour(color:Color):
	
	panel.bg_color = color
	
func setBorder(color:Color):
	
	panel.border_color = color

	
	
