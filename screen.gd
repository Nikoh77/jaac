extends RichTextLabel

func _ready():
	set_scroll_follow(true)
#    set_process(true)
#    set_process_input(true)

	
func _input(event):
	if event.[InputEventKey]:
#	if event.is_match(InputEventKey) and !event.is_echo() and event.is_pressed():
		print('evento')
		var keySymbol = PackedByteArray([event.get_keycode()]).get_string_from_ascii()
		if event.get_keycode() == 16777222 || event.get_keycode() == 16777221:
			Telnet.client.put_utf8_string(str("\r"))
		elif event.get_keycode() > 16777349 and event.get_keycode() < 16777360:
			Telnet.client.put_utf8_string(str(event.scancode - 16777350))
#		elif (event.get_keycode_with_modifiers().is_shift_pressed()):
#			Telnet.client.put_utf8_string(str(keySymbol))
		else:
			Telnet.client.put_utf8_string(str(keySymbol).to_lower())
