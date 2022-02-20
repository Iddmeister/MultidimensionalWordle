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
	
	var word:String
	
	for l in range(5):
		
		word += grid.getLetter(grid.currentLine, l)
	
	checkWord(word, grid.currentLine, int(board.name))
	grid.enter()
	
	pass
	
func addLetter(letter:String):
	
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	grid.addLetter(letter)
	
func setLetter(line:int, c:int, l:String, color:Color=Color(1, 1, 1, 1)):
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	grid.setLetter(line, c, l, color)
	
	
func removeLetter():
	var board = $"3DGrid".selectedBoard
	var grid = board.get_node("Viewport/Grid")
	grid.removeLetter()
	
func checkWord(word:String, x:int, y:int):
	
	var board = $"3DGrid".selectedBoard
	var grid:Grid = board.get_node("Viewport/Grid")
	
	var answerX = words.x[x]
	var answerY = words.y[y]
	
	for letter in range(word.length()):
		
		if word[letter] == answerX[letter] or word[letter] == answerY[letter]:
			setLetter(grid.currentLine, letter, word[letter], correct)
		elif word[letter] in answerX or word[letter] in answerY:
			setLetter(grid.currentLine, letter, word[letter], misplaced)
		else:
			setLetter(grid.currentLine, letter, word[letter], incorrect) 
	pass
