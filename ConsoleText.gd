extends RichTextLabel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$ConsoleBox/Container/ConsoleText.clear()
	for i in range($ConsoleBox/Container/ConsoleText.get_visible_line_count():
		$ConsoleBox/Container/ConsoleText.newline()
	$ConsoleBox/Container/ConsoleText.add_text('Welcome to Misererie')
	$ConsoleBox/Container/ConsoleText.scroll_following = true
	$ConsoleBox/Container/LineEdit.clear()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
