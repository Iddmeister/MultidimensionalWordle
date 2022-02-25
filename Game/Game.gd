extends Node

export var correct:Color
export var misplaced:Color
export var incorrect:Color

var validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var words:Dictionary = {
	
	"x":["HELLO", "SOLVE", "GLAZE", "FLUFF", "SCRUB", "ROUGH"],
	"y":["VEGAN", "STALK", "GRIPE", "BROOD", "FIRED", "PULSE"],
	
}

func _ready():
	pass

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
	
	checkWord(word, grid.currentLine, int(board.name))
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
				setLetter(grid.currentLine, letter, word[letter], misplaced)
			"@":
				setLetter(grid.currentLine, letter, word[letter], correct)
			_:
				setLetter(grid.currentLine, letter, word[letter], incorrect)
		
	#print("t: "+tWord+", x: "+answerX+", y: "+answerY)
		
	pass
