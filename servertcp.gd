extends Node

const server_ip = "40.121.198.16" # Change this to your server IP
const server_port = 3456

onready var server_connection = StreamPeerTCP.new()
onready var server_connection_status = -1
onready var player_name = "Godotchan"
onready var packets_arrived = false

onready var is_master = 0
onready var other_remote_address = ""
onready var other_private_address = ""
onready var other_remote_port = 0
onready var other_name = ""
onready var strLength = 0

onready var is_connecting_remote = true

signal finished_server_tcp

func connection_status_change(new_status):
	server_connection_status = new_status
	print("Server status: ", new_status)
	
	if (new_status == 2):
		server_connection.put_utf8_string(player_name);
		server_connection.put_utf8_string(IP.get_local_addresses()[1]);	

func start_connection():
	print("Trying to connect...")
	server_connection.connect_to_host(server_ip, server_port)
	
	set_process(true)

func _process(delta):
	if (server_connection.get_status() != server_connection_status):
		connection_status_change(server_connection.get_status())
	if (server_connection.is_connected_to_host() and server_connection.get_available_bytes() > 0 and not packets_arrived):
		packets_arrived = true
		is_master = server_connection.get_u32()
		strLength = server_connection.get_u32()
		other_name = server_connection.get_string(strLength)
		strLength = server_connection.get_u32()
		other_remote_address = server_connection.get_string(strLength)
		other_remote_port = server_connection.get_u32()
		strLength = server_connection.get_u32()
		other_private_address = server_connection.get_string(strLength)
	if (server_connection.is_connected_to_host() and server_connection.get_available_bytes() == 0 and packets_arrived):
		packets_arrived = false
		printt(other_remote_address, other_private_address, other_remote_port, other_name)
		emit_signal("finished_server_tcp")
		server_connection.disconnect_from_host()
		set_process(false)

func _ready():
#	gamestate.connect("connection_failed", self, "on_join_failed")
	pass