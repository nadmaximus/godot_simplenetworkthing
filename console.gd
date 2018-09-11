extends CanvasLayer

const DEFAULT_PORT = 5000
const SERVER_IP = '127.0.0.1'
const MAX_PLAYERS = 64


func _ready():

    # Add some blank lines to the ConsolText so that the welcome message appears at bottom
	$ConsoleBox/Container/ConsoleText.clear()
	for i in range(100):
		$ConsoleBox/Container/ConsoleText.newline()
	writeline('Simple Multiplayer Thing')
	$ConsoleBox/Container/LineEdit.clear()
	$ConsoleBox/Container/LineEdit.grab_focus()


	# Create the server object and attempt to become the server
	# If the port is already in use, attempt to connect as a client
	writeline("Attempting to become server...")
	var host = NetworkedMultiplayerENet.new()
	var err = host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if (err!=OK):
		# if we failed to become the server, we assume that the server is already running,
		# so we attempt to join as a client
		writeline("Port in use, assuming the server is already running.")
		writeline("Attempting to connect to localhost as client...")
		host.create_client(SERVER_IP, DEFAULT_PORT)
	else:
		writeline("Server initialized, waiting for connections")
		$ConsoleBox/Container/Status.text = "Server"
	get_tree().set_network_peer(host)

	get_tree().connect("network_peer_connected",    self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _peer_connected(id):
	# this is called when connection is established - whether that's from client to server,
	# or server receiving connection from a client
	if id == 1:
		# if the id of the peer is 1, it is the server, and we are a client
		writeline("_peer_connected:  Connected to server with id " + str(get_tree().get_network_unique_id()))
		$ConsoleBox/Container/Status.text = "Client id " + str(get_tree().get_network_unique_id())
	else:
		# if the id is not 1, we are the server and the peer is a client
		writeline("_peer_connected: Client " + str(id) + " connected")

func _peer_disconnected(id):
	writeline("_peer_disconnected: Client " + str(id) + "disconnected")
	
func _connected_ok():
	# this is called on clients when connected to server
	writeline("_connected_ok")
	
func _connected_fail():
	# this is called on clients when failure to connect to server
	writeline("_connected_failed")
	
func _server_disconnected():
	# this is called on clients when the server disconnects
	writeline("_server_disconnected")
		
func _process(delta):
	pass

func _on_LineEdit_text_entered(new_text):
	
	# rpc("globalMessage","Peer "+str(get_tree().get_network_unique_id())+": "+ new_text)
	rpc_id(1,"serverMessage", new_text, get_tree().get_network_unique_id())
	# writeline(new_text)
	$ConsoleBox/Container/LineEdit.clear()
	 
remote func serverMessage(new_text, remote_id):
	# receive message from client and send to all connected clients
	writeline("serverMessage: Peer " + str(remote_id) + ": " + new_text)
	rpc("globalMessage","Peer "+str(remote_id)+": "+ new_text)
	
func _on_ConsoleText_meta_clicked(meta):
	OS.shell_open(meta)

remote func globalMessage(new_text):
	writeline("globalMessage: " + new_text)
	
func writeline(text):
	$ConsoleBox/Container/ConsoleText.newline()
	$ConsoleBox/Container/ConsoleText.append_bbcode(text)
	if $ConsoleBox/Container/ConsoleText.get_line_count() > 100:
		$ConsoleBox/Container/ConsoleText.remove_line(0)