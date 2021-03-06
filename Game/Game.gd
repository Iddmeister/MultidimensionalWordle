extends Node

export var completelyCorrect:Color
export var correct:Color
export var misplaced:Color
export var incorrect:Color
export var resigned:Color

export var onlyAllowedGuesses:bool = true
export var randomizeWords:bool = true
export var gameSeed:String = ""
export var wordsToReveal = ""


var allowedWordsPath:String = "res://words/wordle-allowed-guesses.txt"
var validSolutionWordsPath:String = "res://words/wordle-answers-alphabetical.txt"
var allowedWords:Array = []

var validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var numberCorrect = 0
var gameOver:bool = false


var words:Dictionary = {
	
	"x":["HELLO", "SOLVE", "GLAZE", "FLUFF", "SCRUB", "ROUGH"],
	"y":["VEGAN", "STALK", "GRIPE", "BROOD", "FIRED", "PULSE"],
	
}

var wordsCorrect:Dictionary = {
	
	"x":[false, false, false, false, false, false],
	"y":[false, false, false, false, false, false],
	
}

var wordsEntered:Array = [[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false]]
var xUnrevealed = 6
var yUnrevealed = 6
var unrevealedArray:Array = [[0,1,2,3,4,5],[0,1,2,3,4,5]] # I suck at programming so I have to bodge everything to make up for it. Don't mind all these arrays :) 
var integerToReveal = int(0)

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
	
	$UI/CenterContainer/NewGamePopup.popup()
	
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
			
		if event.is_action("center"):
			$"3DGrid".moveCam($"3DGrid".selectedBoard)
		elif event.is_action("rotCam"):
			$"3DGrid".moveCam($"3DGrid".selectedBoard)
			yield(get_tree().create_timer(0), "timeout")
			$"3DGrid".moveCam($"3DGrid".selectedBoard, true)
			
			

func submitWord():
	if gameOver == true:
		pass
	else:
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
				
	print("bozo")
		
	
	var answerX = words.x[x]
	var answerY = words.y[y]
	
	if word == answerX or word == answerY:
		
		if wordsCorrect["x"][x] and wordsCorrect["y"][y]:
			for letter in range(word.length()):
		
				setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)#completelyCorrect)
		elif wordsCorrect["x"][x]:
			for letter in range(word.length()):
		
				setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)#completelyCorrect)
				
			if word == answerY:
				
				wordsCorrect["y"][y] = true
				for letter in range(word.length()):
					
					grid.get_node("a"+String(letter)).text = word[letter].to_upper()
					grid.get_node("a"+String(letter)).setColour(correct)
					
					
		elif wordsCorrect["y"][y]:
			for letter in range(word.length()):
		
				setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)#completelyCorrect)

			if word == answerX:
				
				wordsCorrect["x"][x] = true
				
				for letter in range(word.length()):
					
					var answerGrid = $"3DGrid".get_node("Answer").get_node("Viewport/Grid")
					answerGrid.setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)
		else:
			if word == answerY:
				
				wordsCorrect["y"][y] = true
				for letter in range(word.length()):
					
					grid.get_node("a"+String(letter)).text = word[letter].to_upper()
					grid.get_node("a"+String(letter)).setColour(correct)
					
			if word == answerX:
				
				wordsCorrect["x"][x] = true
				
				for letter in range(word.length()):
					
					var answerGrid = $"3DGrid".get_node("Answer").get_node("Viewport/Grid")
					answerGrid.setLetter(grid.currentLine, letter, word[letter].to_upper(), correct)
			
		updateRevealButton(y,x)
			
		
	
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
	
	updateRevealButton(y,x)
	
	pass

func updateRevealButton(y,x):
	if (not false in wordsCorrect["x"]) and (not false in wordsCorrect["y"]):
		get_node("UI/PanelContainer/MarginContainer/VBoxContainer/Reveal").hide()
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
					get_node("UI/PanelContainer/MarginContainer/VBoxContainer/Reveal").text="Reveal Words"


func _on_Center_pressed():
	$"3DGrid".moveCam($"3DGrid".selectedBoard)
	yield(get_tree().create_timer(0), "timeout")
	$"3DGrid".moveCam($"3DGrid".selectedBoard, true)


func _on_New_pressed():
	$UI/CenterContainer/NewGamePopup.popup()


func _on_Start_pressed():
	$"3DGrid".show()
	wordsCorrect = {
		"x":[false, false, false, false, false, false],
		"y":[false, false, false, false, false, false],
	}
	if $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed.text == "":
		randomize()
		gameSeed = String(int(rand_range(0, 99999)))
		reset(gameSeed)
	else:
		gameSeed = $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed.text
		reset(gameSeed)
	if $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer3/Words.value == 0:
		pass
	else:
		wordsToReveal = $UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer3/Words.value
		xUnrevealed = 6
		yUnrevealed = 6
		unrevealedArray = [[0,1,2,3,4,5],[0,1,2,3,4,5]] # I suck at programming so I have to bodge everything to make up for it. Don't mind all these arrays :) 
		for numberRevealed in range(wordsToReveal):	
			randomize()
			integerToReveal = int(round((rand_range(.5,xUnrevealed+yUnrevealed+.5))))
			if integerToReveal > xUnrevealed:
				integerToReveal -= xUnrevealed
				for letter in range(len(words["y"][integerToReveal-1])):
					(get_node("3DGrid/"+String(unrevealedArray[0][integerToReveal-1])).get_node("Viewport/Grid")).get_node("a"+String(letter)).text = words["y"][unrevealedArray[0][integerToReveal-1]][letter].to_upper()
					(get_node("3DGrid/"+String(unrevealedArray[0][integerToReveal-1])).get_node("Viewport/Grid")).get_node("a"+String(letter)).setColour(completelyCorrect)
				wordsCorrect["y"][unrevealedArray[0][integerToReveal-1]] = true
				unrevealedArray[0].remove(integerToReveal-1)
				yUnrevealed -= 1
			else:
				for letter in range(len(words["x"][integerToReveal-1])):
					var answerGrid = $"3DGrid".get_node("Answer").get_node("Viewport/Grid")
					answerGrid.setLetter((unrevealedArray[1][integerToReveal-1]), letter, words["x"][unrevealedArray[1][integerToReveal-1]][letter].to_upper(), completelyCorrect)
				wordsCorrect["x"][unrevealedArray[1][integerToReveal-1]] = true
				unrevealedArray[1].remove(integerToReveal-1)
				xUnrevealed -= 1
				
	gameOver = false
	wordsEntered = [[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false],[false, false, false, false, false, false]]
	get_node("UI/PanelContainer/MarginContainer/VBoxContainer/Reveal").text="Give Up"
	get_node("UI/PanelContainer/MarginContainer/VBoxContainer/Reveal").show()
	
	print(gameSeed)
	$UI/PanelContainer/MarginContainer/VBoxContainer/Seed.text = "Seed: "+String(gameSeed)
		
	$UI/CenterContainer/NewGamePopup/VBoxContainer/HBoxContainer/Seed.text = ""
		
	$UI/CenterContainer/NewGamePopup.hide()
		

func _on_Cancel_pressed():
	$UI/CenterContainer/NewGamePopup.hide()
	

func _on_Resign_pressed():
	
	gameOver = true
	get_node("UI/PanelContainer/MarginContainer/VBoxContainer/Reveal").hide()
	
	for depth in range(6):
		for dimension in "xy":
			if wordsCorrect[dimension][depth] == true:
				pass
			else:
				if dimension == "x":
					for letter in range((words[dimension][depth]).length()):
				
						var answerGrid = $"3DGrid".get_node("Answer").get_node("Viewport/Grid")
						answerGrid.setLetter((depth), letter, words[dimension][depth][letter].to_upper(), resigned)
				else:
					for letter in range((words[dimension][depth]).length()):
						(get_node("3DGrid/"+String(depth)).get_node("Viewport/Grid")).get_node("a"+String(letter)).text = words[dimension][depth][letter].to_upper()
						(get_node("3DGrid/"+String(depth)).get_node("Viewport/Grid")).get_node("a"+String(letter)).setColour(resigned)
			
	
