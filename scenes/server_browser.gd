class_name ServerBrowser extends Node

@export var listen_port: int = 8911
@export var broadcast_port: int = 8912
@export var broadcast_address: String = ""

@onready var broadcast_timer: Timer = $BroadcastTimer

var broadcaster: PacketPeerUDP
var listener: PacketPeerUDP

var local_room_info = { "name": "", "player_count": 0 }
var server_info_list = {} #note: no player should have the same name. otherwise, if they're both hosting servers, they'll override each other
const SERVER_TIMEOUT_SECONDS: float = 3.0

signal failed_listen_port_bind

signal found_server(room_name: String, ip: String, player_count: int)
signal updated_server(room_name: String, ip: String, player_count: int)
signal removed_server(room_name: String)

func _ready():
	set_up_listener()
	broadcast_address = get_subnet_broadcast()

func get_best_local_ip() -> String:
	var ips = IP.get_local_addresses()
	for ip in ips:
		if ip.begins_with("192."):
			return ip
	for ip in ips:
		if ip.begins_with("10."):
			return ip
	for ip in ips:
		if ip.begins_with("172."):
			return ip
	return ""

func get_subnet_broadcast():
	var local_ip = get_best_local_ip()
	if local_ip == "":
		return "255.255.255.255"
	var parts = local_ip.split(".")
	return "%s.%s.%s.255" % [parts[0], parts[1], parts[2]] #maybe change to detect subnet mask 

func set_up_listener():
	listener = PacketPeerUDP.new()
	var listener_bind_ok = listener.bind(listen_port)
	if listener_bind_ok == OK:
		print("Bound to listen port " + str(listen_port) + " successful")
	else:
		print("Failed to bind to listen port!")
		failed_listen_port_bind.emit()

func _process(delta: float) -> void:
	cleanup_server_list(delta)
	if listener.get_available_packet_count() > 0:
		update_server_list()

func cleanup_server_list(delta: float):
	for room_name in server_info_list.keys():
		server_info_list[room_name].seconds_since_broadcast += delta
		if server_info_list[room_name].seconds_since_broadcast >= SERVER_TIMEOUT_SECONDS:
			server_info_list.erase(room_name)
			removed_server.emit(room_name)

func update_server_list():
	var server_ip = listener.get_packet_ip()
	var server_port = listener.get_packet_port()
	var bytes = listener.get_packet()
	var data = bytes.get_string_from_utf16()
	var room_info = JSON.parse_string(data)
	
	print(" server IP: " + server_ip + " server port: " + str(server_port) + " room info: " + str(room_info))
	if server_info_list.has(room_info.name):
		server_info_list[room_info.name].player_count = room_info.player_count
		server_info_list[room_info.name].seconds_since_broadcast = 0.0
		updated_server.emit(room_info.name, server_ip, room_info.player_count)
	else:
		server_info_list[room_info.name] = {
			"ip": server_ip,
			"player_count": room_info.player_count,
			"seconds_since_broadcast": 0.0
		}
		found_server.emit(room_info.name, server_ip, room_info.player_count)

func set_up_broadcast(name):
	local_room_info.name = name
	update_local_room_player_count()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcast_address, listen_port)
	
	var broadcaster_bind_ok = broadcaster.bind(broadcast_port)
	if broadcaster_bind_ok == OK:
		print("Bound to broadcast port " + str(broadcast_port) + " successful")
		broadcast_timer.start()
	else:
		print("Failed to bind to broadcast port!")

func _on_broadcast_timer_timeout() -> void:
	print("broadcasting game!")
	update_local_room_player_count()
	
	var data = JSON.stringify(local_room_info)
	var packet = data.to_utf16_buffer()
	broadcaster.put_packet(packet)

func update_local_room_player_count():
	local_room_info.player_count = multiplayer.get_peers().size() + 1

func clean_up():
	listener.close()
	broadcast_timer.stop()
	if broadcaster != null:
		broadcaster.close()

func _exit_tree():
	clean_up()
