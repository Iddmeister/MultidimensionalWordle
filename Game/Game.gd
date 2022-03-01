extends Node

export var correct:Color
export var misplaced:Color
export var incorrect:Color

export var onlyAllowedGuesses:bool = true
export var randomizeWords:bool = true
export var gameSeed:int = -1

var allowedWordsPath:String = "res://words/wordle-allowed-guesses.txt"
var validSolutionWordsPath:String = "res://words/wordle-answers-alphabetical.txt"
var allowedWords:Array = []

var validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var words:Dictionary = {
	
	"x":["HELLO", "SOLVE", "GLAZE", "FLUFF", "SCRUB", "ROUGH"],
	"y":["VEGAN", "STALK", "GRIPE", "BROOD", "FIRED", "PULSE"],
	
}


func _ready():
	
	if gameSeed == -1:
		randomize()
		gameSeed = rand_range(0, 99999)
		seed(gameSeed)
	else:
		seed(gameSeed)
		
	$UI/PanelContainer/MarginContainer/VBoxContainer/Seed.text = "Seed: "+String(gameSeed)
	
	var f  = File.new()
	
	if randomizeWords:
		
		var validSolutions = []
		
		f.open(validSolutionWordsPath, File.READ)
		
		while not f.eof_reached():
			validSolutions.append(f.get_line())
			
		f.close()
		
		words.x = []
		words.y = []

		var i = 0

		while i < 6:
			
			validSolutions.shuffle()
			var w = validSolutions[0]
			
			if not w in words.x:
				words.x.append(w)
				i += 1
				
		i = 0
				
		while i < 6:
			
			validSolutions.shuffle()
			var w = validSolutions[0]
			
			if not w in words.x and not w in words.y:
				words.y.append(w)
				i += 1
				
		#print(words)
			
		
	
	if not onlyAllowedGuesses:
		return

	f.open(allowedWordsPath, File.READ)

	while not f.eof_reached():
		allowedWords.append(f.get_line())
		
	f.close()
	
	f.open(validSolutionWordsPath, File.READ)
	
	while not f.eof_reached():
		allowedWords.append(f.get_line())
		
	f.close()
	

func _input(event):
	
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
			
			

func submitWord():
	
	var board = $"3DGrid".selectedBoard
	var grid:Grid = board.get_node("Viewport/Grid")
	
	if grid.complete:
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
	if grid.complete:
		return
	grid.addLetter(letter)
	
func setLetter(line:int, c:int, l:String, color:Color=Color(1, 1, 1, 1)):
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete:
		return
	grid.setLetter(line, c, l, color)
	
	
func removeLetter():
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	if grid.complete:
		return
	grid.removeLetter()
	
	
func checkWord(word:String, x:int, y:int):
	
	var board = $"3DGrid".selectedBoard
	var grid:Grid = board.get_node("Viewport/Grid")
	if grid.complete:
		return
		
	
	var answerX = words.x[x]
	var answerY = words.y[y]
	
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
