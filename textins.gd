extends LineEdit

func _ready():
	text_submitted.connect(self.convert)

func convert(new_string):
	var x:PackedByteArray
	x.append((int(new_string)))
	print(x)
	Telnet.send(x)
	self.clear()
	pass
	
