extends GridContainer

class_name Grid

export var selectedColor:Color
var currentLine:int = 0
var currentChar:int = 0
var completedLines:Array = []

var complete:bool = false

func selectLine(line:int):
	
	currentLine = line
	
	for c in range(5):
		
		currentChar = c
		if isLetterEmpty():
			currentChar = min(4, currentChar)
			break
	
	get_tree().call_group("Letter", "setBorder", Color(1, 1, 1, 1))
	
	for l in range(5):
		get_child((line*5)+l).call_deferred("setBorder", selectedColor)
	
	pass

func isLetterEmpty():
	return get_child((currentLine*5)+currentChar).text == ""

func removeLetter():
	
	if currentLine in completedLines:
		return
	
	if not isLetterEmpty():
		setLetter(currentLine, currentChar, "")
	else:
		currentChar = int(max(0, currentChar-1))
		setLetter(currentLine, currentChar, "")

func addLetter(letter:String):
	
	if currentLine in completedLines:
		return
	
	if not isLetterEmpty():
		return
		
	setLetter(currentLine, currentChar, letter)
	currentChar = int(min(4, currentChar+1))
	
	pass
	
func enter():
	
	if currentLine in completedLines:
		return
	
	if completedLines.size() >= 6:
		return false
	
	if not currentChar >= 4:
		return false
		
	completedLines.append(currentLine)
		
	currentChar = 0
	
	get_tree().call_group("Letter", "setBorder", Color(1, 1, 1, 1))
	
	if completedLines.size() >= 6:
		complete = true
		return true
		
	while true:
		
		currentLine += 1
		
		if currentLine > 5:
			currentLine = 0
			
		if currentLine in completedLines:
			continue
		else:
			selectLine(currentLine)
			break
		
		
	return true
	
	
	pass

func setLetter(line:int, c:int, l:String, color:Color=Color(1, 1, 1, 1)):
	
	var letter = get_child((line*5)+c)
	
	letter.text = l
	
	if not color == Color(1, 1, 1 ,1):
		letter.setColour(color)
	
	pass
	
func getLetter(line:int, c:int):
	return get_child((line*5)+c).text
