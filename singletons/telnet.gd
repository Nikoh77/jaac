extends Node

var client: StreamPeerTCP = StreamPeerTCP.new()
var hostINI: String = 'react-bbs.nikoh.it'
var portINI: int = 2323
var _status: int
var RECONNECT_TIMEOUTINI: float = 3.0

signal connected
signal data
signal disconnected
signal error

func _ready():
	await Settings.settingsLoaded
	_status = client.get_status()
	self.connected.connect(self._handle_client_connected)
	self.disconnected.connect(self._handle_client_disconnected)
	self.error.connect(self._handle_client_error)
	self.data.connect(self._handle_client_data)
	connect_to_host(hostINI, portINI)
	
func _process(delta):
	client.poll()
	var new_status: int = client.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			client.STATUS_NONE:
				print("Disconnected from host.")
				emit_signal("disconnected")
			client.STATUS_CONNECTING:
				print("Connecting to host.")
			client.STATUS_CONNECTED:
				print("Connected to host.")
				emit_signal("connected")
			client.STATUS_ERROR:
				print("Error with socket stream.")
				emit_signal("error")

	if _status == client.STATUS_CONNECTED:
		var available_bytes: int = client.get_available_bytes()
		if available_bytes > 0:
			print("available bytes: ", available_bytes)
			var data: Array = client.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				print("Error getting data from stream: ", data[0])
				emit_signal("error")
			else:
				emit_signal("data", data[1])
	
func connect_to_host(host: String, port: int) -> void:
	print("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = client.STATUS_NONE
	if client.connect_to_host(host, port) != OK:
		print("Error connecting to host.")
		emit_signal("error")

func send(data: PackedByteArray) -> bool:
	if _status != client.STATUS_CONNECTED:
		print("Error: Stream is not currently connected.")
		return false
	var error: int = client.put_data(data)
	if error != OK:
		print("Error writing to stream: ", error)
		return false
	return true

func _connect_after_timeout(timeout: float) -> void:
	await get_tree().create_timer(timeout).timeout # Delay for timeout
	connect_to_host(hostINI, portINI)

func _handle_client_connected() -> void:
	print("Client connected to server.")

func _handle_client_data(data: PackedByteArray) -> void:
	get_node('/root/Main/Control/Screen').add_text(data.get_string_from_utf8())
	print("Client data: ", data.get_string_from_utf8())
#	var message: PackedByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
#	send(message)

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	if RECONNECT_TIMEOUTINI:
		_connect_after_timeout(RECONNECT_TIMEOUTINI) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	if RECONNECT_TIMEOUTINI:
		_connect_after_timeout(RECONNECT_TIMEOUTINI) # Try to reconnect after 3 seconds

