extends Label

enum {INCORRECT, MISPLACED, CORRECT}

export var incorrect:Color
export var correct:Color
export var misplaced:Color

onready var panel:StyleBoxFlat = get_stylebox("normal")

func setLetter(letter:String, state:int):
	
	match state:
		
		INCORRECT:
			panel.bg_color = incorrect
		MISPLACED:
			panel.bg_color = misplaced
		CORRECT:
			panel.bg_color = correct
	
	
