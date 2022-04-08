extends Node

export var correct:Color
export var misplaced:Color
export var incorrect:Color
export var resigned:Color

export var onlyAllowedGuesses:bool = true
export var randomizeWords:bool = true
export var gameSeed:String = ""
export var dailyMode:bool = true


var allowedWordsPath:String = "res://words/wordle-allowed-guesses.txt"
var validSolutionWordsPath:String = "res://words/wordle-answers-alphabetical.txt"
var allowedWords:Array = []

var validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var validCharacters = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var numberCorrect = 0
var gameOver:bool = false

signal wordSubmitted(grid, line)

onready var grid3D = $"3DGrid"

var words:Dictionary = {
	
	"x":["HELLO", "SOLVE", "GLAZE", "FLUFF", "SCRUB", "ROUGH"],
	"y":["VEGAN", "STALK", "GRIPE", "BROOD", "FIRED", "PULSE"],
	
}

var wordsCorrect:Dictionary = {
	
	"x":[false, false, false, false, false, false],
	"y":[false, false, false, false, false, false],
	
}

var wordsEntered:Array = [[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false]]

func reset(s:String):
	
	words = generateAnswers(s)
	
	get_tree().call_group("Letter", "setBorder", Color(1, 1, 1, 1))
	
	for board in grid3D.get_children():
		board.get_node("Viewport/Grid").clear()
		board.get_node("Back").modulate = Color(0.058824, 0.058824, 0.058824)
		
	grid3D.selectedBoard = grid3D.get_child(6)
	grid3D.selectedBoard.get_node("Viewport/Grid").selectLine(0)
	grid3D.selectedBoard.get_node("Back").modulate = grid3D.selectedBoard.get_node("Viewport/Grid").selectedColor
	
	pass

func _ready():
	
	if gameSeed == "":
		
		var date:Dictionary = OS.get_date()
		var dateString = "%s/%s/%s" % [date["day"], date["month"], date["year"]]
		$UI/Stuff/CenterContainer/Seed.text = dateString
		#Hash the date to make cheating harder
		#gameSeed = String(dateString.hash())
		gameSeed = dateString
		
		pass
	
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
		
		pressedKey(letter)
		

var typingOnBoard:bool = true

onready var seedEdit = $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed

func pressedKey(letter:String):
	
	if not typingOnBoard:
		
		if letter == "Enter":
			return
		if letter == "BackSpace":
			if seedEdit.text.length() > 0:
				seedEdit.text = seedEdit.text.substr(0, seedEdit.text.length()-1)
			return
			
		if not letter in validCharacters:
			return
		
		if seedEdit.text.length() < seedEdit.max_length:
			seedEdit.text += letter
		
		return
	
	if letter == "Enter":
		
		submitWord()
		
	elif letter == "BackSpace":
		
		removeLetter()
		
	elif letter in validLetters:
		
		addLetter(letter)


func submitWord():
	if gameOver == true:
		pass
	else:
		var board = grid3D.selectedBoard
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
		emit_signal("wordSubmitted", grid, grid.currentLine)
		grid.enter()
		
		pass
		
func addLetter(letter:String):
	
	var board = grid3D.selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	grid.addLetter(letter)
	
func setLetter(line:int, c:int, l:String, color:Color=Color(1, 1, 1, 1), state:int=NORM):
	var board = grid3D.selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	grid.setLetter(line, c, l, color, state)
	
	
func removeLetter():
	var board = grid3D.selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	grid.removeLetter()
	
	
enum {NORM, INCORRECT, MISPLACED, CORRECT}
	
func checkWord(word:String, x:int, y:int):
	
	var board = grid3D.selectedBoard
	var grid:Grid = board.get_node("Viewport/Grid")
	if grid.complete or board.name == "Answer":
		return
	
	var answerX = words.x[x]
	var answerY = words.y[y]
	
	if word == answerX or word == answerY:
		
		for letter in range(word.length()):
	
			setLetter(grid.currentLine, letter, word[letter].to_upper(), correct, CORRECT)
			
		if word == answerY:
			
			wordsCorrect["y"][y] = true
			
			for letter in range(word.length()):
				
				grid.get_node("a"+String(letter)).text = word[letter].to_upper()
				grid.get_node("a"+String(letter)).setColour(correct)
				
		if word == answerX:
			
			wordsCorrect["x"][x] = true
			
			for letter in range(word.length()):
				
				var answerGrid = grid3D.get_node("Answer").get_node("Viewport/Grid")
				answerGrid.setLetter(grid.currentLine, letter, word[letter].to_upper(), correct, CORRECT)
			
		updateRevealButton(y,x)
			
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
				setLetter(grid.currentLine, letter, word[letter].to_upper(), misplaced, MISPLACED)
			"@":
				setLetter(grid.currentLine, letter, word[letter].to_upper(), correct, CORRECT)
			_:
				setLetter(grid.currentLine, letter, word[letter].to_upper(), incorrect, INCORRECT)
		
	#print("t: "+tWord+", x: "+answerX+", y: "+answerY)
	
	updateRevealButton(y,x)
	
	pass

func updateRevealButton(y,x):
	if (not false in wordsCorrect["x"]) and (not false in wordsCorrect["y"]):
		get_node("UI/Stuff/GiveUp").hide()
	else:
		wordsEntered[y][x] = true
		for gridNumber in range(6):
			for rowNumber in range(6):
				if wordsEntered[rowNumber][gridNumber] == false:
					if wordsCorrect["x"][gridNumber] and wordsCorrect["y"][rowNumber]:
						pass
					else:
						return
			if gridNumber == 5:
					get_node("UI/Stuff/GiveUp").text="Reveal Words"



func newGame(s:String):
		
	gameSeed = s
	reset(gameSeed)
	gameOver = false
	wordsCorrect = {
		"x":[false, false, false, false, false, false],
		"y":[false, false, false, false, false, false],
	}
	wordsEntered = [[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false]]
	get_node("UI/Stuff/GiveUp").text="Give Up"
	get_node("UI/Stuff/GiveUp").show()
	
	print(gameSeed)
	$UI/Stuff/CenterContainer/Seed.text = String(gameSeed)

func _on_NewGame_pressed():
	
	$UI/Menu/Animation.play("NewGame")
	$UI/CenterContainer/NewGamePopup.show()
	typingOnBoard = false

func _on_Start_pressed():

	$UI/Cover2.hide()
	$UI/CenterContainer/NewGamePopup.hide()
	if seedEdit.text == "":
		randomize()
		newGame(String(int(rand_range(0, 99999))))
	else:
		newGame(String(seedEdit.text))
	seedEdit.text = ""
	typingOnBoard = true

func _on_Cancel_pressed():
	$UI/CenterContainer/NewGamePopup.hide()
	$UI/Cover2.hide()
	seedEdit.text = ""
	typingOnBoard = true


func _on_GiveUp_pressed():
	$UI/CenterContainer/GiveUpConfirmation.show()



func _on_ConfirmGiveUp_pressed():
	
	$UI/CenterContainer/GiveUpConfirmation.hide()
	
	gameOver = true
	get_node("UI/Stuff/GiveUp").hide()
	
	for depth in range(6):
		for dimension in "xy":
			if wordsCorrect[dimension][depth] == true:
				pass
			else:
				if dimension == "x":
					for letter in range((words[dimension][depth]).length()):
				
						var answerGrid = grid3D.get_node("Answer").get_node("Viewport/Grid")
						answerGrid.setLetter((depth), letter, words[dimension][depth][letter].to_upper(), resigned)
				else:
					for letter in range((words[dimension][depth]).length()):
						(get_node("3DGrid/"+String(depth)).get_node("Viewport/Grid")).get_node("a"+String(letter)).text = words[dimension][depth][letter].to_upper()
						(get_node("3DGrid/"+String(depth)).get_node("Viewport/Grid")).get_node("a"+String(letter)).setColour(resigned)
			
	

func _on_CancelGiveUp_pressed():
	$UI/CenterContainer/GiveUpConfirmation.hide()
