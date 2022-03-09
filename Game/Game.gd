extends Node

export var completelyCorrect:Color
export var correct:Color
export var misplaced:Color
export var incorrect:Color

export var onlyAllowedGuesses:bool = true
export var randomizeWords:bool = true
export var gameSeed:String = ""

var allowedWordsPath:String = "res://words/wordle-allowed-guesses.txt"
var validSolutionWordsPath:String = "res://words/wordle-answers-alphabetical.txt"
var allowedWords:Array = []

var validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


var words:Dictionary = {
	
	"x":["HELLO", "SOLVE", "GLAZE", "FLUFF", "SCRUB", "ROUGH"],
	"y":["VEGAN", "STALK", "GRIPE", "BROOD", "FIRED", "PULSE"],
	
}

func reset(s:String):
	
	words = generateAnswers(s)
	
	get_tree().call_group("Letter", "setBorder", Color(1, 1, 1, 1))
	
	for board in $"3DGrid".get_children():
		board.get_node("Viewport/Grid").clear()
		board.get_node("Back").get_active_material(0).albedo_color = Color(0.058824, 0.058824, 0.058824)
		
	$"3DGrid".selectedBoard = $"3DGrid".get_child(6)
	$"3DGrid".selectedBoard.get_node("Viewport/Grid").selectLine(0)
	$"3DGrid".selectedBoard.get_node("Back").get_active_material(0).albedo_color = $"3DGrid".selectedBoard.get_node("Viewport/Grid").selectedColor
	
	pass

func _ready():
	
	if gameSeed == "":
		randomize()
		gameSeed = String(int(rand_range(0, 99999)))
		
	$UI/PanelContainer/MarginContainer/VBoxContainer/Seed.text = "Seed: "+String(gameSeed)
	
	if randomizeWords:
		words = generateAnswers(gameSeed)
		
	
	if not onlyAllowedGuesses:
		return
		
	var f = File.new()

	f.open(allowedWordsPath, File.READ)

	while not f.eof_reached():
		allowedWords.append(f.get_line())
		
	f.close()
	
	f.open(validSolutionWordsPath, File.READ)
	
	while not f.eof_reached():
		allowedWords.append(f.get_line())
		
	f.close()
	
	
	
func generateAnswers(s:String) -> Dictionary:
	
	seed(s.hash())
	
	var newWords:Dictionary = {"x":[], "y":[]}
	
	var f  = File.new()
	
		
	var validSolutions = []
	
	f.open(validSolutionWordsPath, File.READ)
	
	while not f.eof_reached():
		validSolutions.append(f.get_line())
		
	f.close()

	var i = 0

	while i < 6:
		
		var w = validSolutions[int(rand_range(0, validSolutions.size()))]
		
		if not w in newWords.x:
			newWords.x.append(w)
			i += 1
			
	i = 0
			
	while i < 6:
		
		var w = validSolutions[int(rand_range(0, validSolutions.size()))]
		
		if not w in newWords.x and not w in newWords.y:
			newWords.y.append(w)
			i += 1
			
	return newWords
	

func _unhandled_key_input(event):
	
	if event is InputEventKey:
		
		if not event.is_pressed():
			return
		
		var letter = OS.get_scancode_string(event.scancode)
		
		if letter == "Enter":
			
			submitWord()
			
		elif letter == "BackSpace":
			
			removeLetter()
			
		elif letter in validLetters:
			
			addLetter(letter)
			
		elif event.is_action("center"):
			$"3DGrid".moveCam($"3DGrid".selectedBoard)
		elif event.is_action("rotCam"):
			$"3DGrid".moveCam($"3DGrid".selectedBoard, true)
			
			

func submitWord():
	
	var board = $"3DGrid".selectedBoard
	var grid:Grid = board.get_node("Viewport/Grid")
	
	if grid.complete or board.name == "Answer":
		return
		
	if grid.currentChar < 4 or grid.isLetterEmpty():
		return
	
	var word:String
	
	for l in range(5):
		
		word += grid.getLetter(grid.currentLine, l)
		
		
		
	if onlyAllowedGuesses:
		if not (word.to_lower() in allowedWords):
			return
	
	checkWord(word.to_lower(), grid.currentLine, int(board.name))
	grid.enter()
	
	pass
	
func addLetter(letter:String):
	
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	grid.addLetter(letter)
	
func setLetter(line:int, c:int, l:String, color:Color=Color(1, 1, 1, 1)):
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	grid.setLetter(line, c, l, color)
	
	
func removeLetter():
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	grid.removeLetter()
	
	
func checkWord(word:String, x:int, y:int):
	
	var board = $"3DGrid".selectedBoard
	var grid:Grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	
		
	
	var answerX = words.x[x]
	var answerY = words.y[y]
	
	if word == answerX or word == answerY:
		
		for letter in range(word.length()):
	
			setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)#completelyCorrect)
			
		if word == answerY:
			
			for letter in range(word.length()):
				
				grid.get_node("a"+String(letter)).text = word[letter].to_upper()
				grid.get_node("a"+String(letter)).setColour(correct)
				
		if word == answerX:
			
			for letter in range(word.length()):
				
				var answerGrid = $"3DGrid".get_node("Answer").get_node("Viewport/Grid")
				answerGrid.setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)
			
			
		return
	
	var tWord:String = word
	
	for letter in range(word.length()):
		
		if word[letter] == answerX[letter] or word[letter] == answerY[letter]:
			
			tWord[letter] = "@"
			
			if word[letter] == answerX[letter]:
				answerX[letter] = "-"
				
			elif word[letter] == answerY[letter]:
				answerY[letter] = "-"
				
				
	#print("t: "+tWord+", x: "+answerX+", y: "+answerY)
				
	for letter in range(word.length()):
		
		if (tWord[letter] in answerX) or (tWord[letter] in answerY):
			
			if tWord[letter] in answerX:
				
				answerX[answerX.find(tWord[letter])] = "-"
				
		## Swap if and elif to change verificationsbhsidfbjsdbva 
				
			elif tWord[letter] in answerY:
				
				answerY[answerY.find(tWord[letter])] = "-"
				
			tWord[letter] = "/"
			
			
	#print("t: "+tWord+", x: "+answerX+", y: "+answerY)
			
			
	for letter in range(word.length()):
		
		match tWord[letter]:
			
			"/":
				setLetter(grid.currentLine, letter, word[letter].to_upper(), misplaced)
			"@":
				setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)
			_:
				setLetter(grid.currentLine, letter, word[letter].to_upper(), incorrect)
		
	#print("t: "+tWord+", x: "+answerX+", y: "+answerY)
		
	pass


func _on_Center_pressed():
	$"3DGrid".moveCam($"3DGrid".selectedBoard, true)


func _on_New_pressed():
	$UI/CenterContainer/NewGamePopup.popup()


func _on_Start_pressed():
	if $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed.text == "":
		randomize()
		gameSeed = String(int(rand_range(0, 99999)))
		reset(gameSeed)
	else:
		gameSeed = $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed.text
		reset(gameSeed)
		
	print(gameSeed)
	$UI/PanelContainer/MarginContainer/VBoxContainer/Seed.text = "Seed: "+String(gameSeed)
		
	$UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed.text = ""
		
	$UI/CenterContainer/NewGamePopup.hide()
		

func _on_Cancel_pressed():
	$UI/CenterContainer/NewGamePopup.hide()
