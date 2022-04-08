extends PanelContainer


func _ready():
	pass


func _on_MenuButton_pressed():
	#get_parent().get_node("MenuButton").hide()
	$Animation.play("Show")


func _on_Back_pressed():
	$Animation.play("Hide")
	yield($Animation, "animation_finished")
	get_parent().get_node("Stuff/MenuButton").show()
