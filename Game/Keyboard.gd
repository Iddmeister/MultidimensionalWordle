tool

extends CenterContainer

var letters = "qwertyuiopasdfghjklzxcvbnm"
var buttons = {}

var normTheme = preload("res://Game/Keyboard/NormButton.tres")
var incorrectTheme = preload("res://Game/Keyboard/IncorrectButton.tres")
var correctTheme = preload("res://Game/Keyboard/CorrectButton.tres")
var misplacedTheme = preload("res://Game/Keyboard/MisplacedButton.tres")

func _ready():
	
	for button in $VBoxContainer/Row1.get_children():
		var letter = letters[0]
		letters.erase(0, 1)
		button.name = letter
		button.text = letter.to_upper()
		button.connect("pressed", self, "pressedKey", [button])
		buttons[button.name] = button
		
	for button in $VBoxContainer/Row2.get_children():
		var letter = letters[0]
		letters.erase(0, 1)
		button.name = letter
		button.text = letter.to_upper()
		button.connect("pressed", self, "pressedKey", [button])
		buttons[button.name] = button
		
	for button in $VBoxContainer/Row3.get_children():
		if button.name == "Back" or button.name == "Enter":
			button.connect("pressed", self, "pressedKey", [button])
			continue
		var letter = letters[0]
		letters.erase(0, 1)
		button.name = letter
		button.text = letter.to_upper()
		button.connect("pressed", self, "pressedKey", [button])
		buttons[button.name] = button
	
func pressedKey(button):
	match button.name:
		
		"Back":
			get_parent().get_parent().pressedKey("BackSpace")
		"Enter":
			get_parent().get_parent().pressedKey("Enter")
		_:
			get_parent().get_parent().pressedKey(button.name.to_upper())
	pass
	
enum {NORM, INCORRECT, MISPLACED, CORRECT}
	
func setKey(key:String, state:int):
	
	match state:
		
		NORM:
			buttons[key].theme = normTheme
		INCORRECT:
			buttons[key].theme = incorrectTheme
		MISPLACED:
			buttons[key].theme = misplacedTheme
		CORRECT:
			buttons[key].theme = correctTheme


func updateKeys(letters:Dictionary):
	
	
	for button in buttons.keys():
		setKey(button, NORM)
	
	for letter in letters.keys():
		setKey(letter.to_lower(), letters[letter])
	
	pass

	
	
func updateKeyboard(grid, line):
	
	var allLetters = grid.getLetters()
	
	for x in range(6):
		var board = get_parent().get_parent().get_node("3DGrid")
		allLetters += board.get_node(String(x)).get_node("Viewport/Grid").getLineLetters(line)
		
	var letterStates:Dictionary = {}
		
	for letter in allLetters:
		
		if letter.state == NORM:
			continue
		
		if letter.text in letterStates:
			if letterStates[letter.text] == CORRECT:
				continue
			elif letter.state == CORRECT:
				letterStates[letter.text] = CORRECT
				continue
			elif letter.state == MISPLACED:
				letterStates[letter.text] = MISPLACED
		else:
			letterStates[letter.text] = letter.state
	
	
	updateKeys(letterStates)
