tool

extends CenterContainer

var letters = "qwertyuiopasdfghjklzxcvbnm"


func _ready():
	
	for button in $VBoxContainer/Row1.get_children():
		var letter = letters[0]
		letters.erase(0, 1)
		button.name = letter
		button.text = letter.to_upper()
		button.connect("pressed", self, "pressedKey", [button])
		
	for button in $VBoxContainer/Row2.get_children():
		var letter = letters[0]
		letters.erase(0, 1)
		button.name = letter
		button.text = letter.to_upper()
		button.connect("pressed", self, "pressedKey", [button])
		
	for button in $VBoxContainer/Row3.get_children():
		if button.name == "Back" or button.name == "Enter":
			button.connect("pressed", self, "pressedKey", [button])
			continue
		var letter = letters[0]
		letters.erase(0, 1)
		button.name = letter
		button.text = letter.to_upper()
		button.connect("pressed", self, "pressedKey", [button])
	
func pressedKey(button):
	match button.name:
		
		"Back":
			get_parent().get_parent().pressedKey("BackSpace")
		"Enter":
			get_parent().get_parent().pressedKey("Enter")
		_:
			get_parent().get_parent().pressedKey(button.name.to_upper())
	pass
