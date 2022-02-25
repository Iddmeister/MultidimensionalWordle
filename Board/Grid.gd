extends GridContainer

class_name Grid

var currentLine:int = 0
var currentChar:int = 0

var complete:bool = false

func isLetterEmpty():
	return get_child((currentLine*5)+currentChar).text == ""

func removeLetter():
	
	if not isLetterEmpty():
		setLetter(currentLine, currentChar, "")
	else:
		currentChar = int(max(0, currentChar-1))
		setLetter(currentLine, currentChar, "")

func addLetter(letter:String):
	
	if not isLetterEmpty():
		return
		
	setLetter(currentLine, currentChar, letter)
	currentChar = int(min(4, currentChar+1))
	
	pass
	
func enter():
	
	if currentLine >= 6:
		return false
	
	if not currentChar >= 4:
		return false
		
	currentLine += 1
	currentChar = 0
	
	if currentLine >= 6:
		complete = true
		
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
