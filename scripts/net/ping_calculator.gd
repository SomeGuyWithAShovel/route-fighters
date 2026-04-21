extends Node
class_name PingCalculator

# JSP si Godot est bien pour calculer le ping...

const SERVER_RTT_BUFFER_SIZE := 10;
const TIME_BETWEEN_PINGS := 1.0;
const TIME_WAITING_FOR_PINGS := 0.5; # Tant que c'est inférieur à TIME_BETWEEN_PINGS

var ping_results : Array[int];
# Ping = temps avant d'atteindre l'autre client
var current_ping : int;

# Temps serveur le plus récent enregistré
var last_calculated_server_time : int;
# Temps client associé au temps serveur le plus récent enregistré
var associated_client_time : int;

var send_pings_timer : Timer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		send_pings_timer.timeout.connect(send_pings);
		send_pings_timer.start(TIME_BETWEEN_PINGS);
	
func get_server_time() -> int:
	@warning_ignore("integer_division")
	var associated_server_time : int = last_calculated_server_time + current_ping/2;
	var client_time_diff = Time.get_ticks_msec() - associated_client_time;
	
	return associated_server_time + client_time_diff;
	
func send_pings() -> void:
	ping_results.clear();
	for i in range(SERVER_RTT_BUFFER_SIZE):
		Server_request_time.rpc_id(1, Time.get_ticks_msec());
	await get_tree().create_timer(TIME_WAITING_FOR_PINGS).timeout;
	calculate_ping();
	
func calculate_ping() -> void:
	var ordered_pings := ping_results.duplicate();
	ordered_pings.sort();
	var average_ping := 0.0;
	for i in range(1, len(ordered_pings)-1):
		average_ping += ordered_pings[i];
	average_ping /= (len(ordered_pings) - 2);
	current_ping = roundi(average_ping);
	
@rpc("any_peer", "call_remote", "unreliable")
func Server_request_time(initial_client_time : int) -> void:
	var sender := multiplayer.get_remote_sender_id();
	Client_recieve_server_time.rpc_id(sender, initial_client_time, Time.get_ticks_msec());
	
@rpc("authority", "call_remote", "unreliable")
func Client_recieve_server_time(initial_client_time : int, server_time : int) -> void:
	var current_client_time : int = Time.get_ticks_msec();
	var RTT := current_client_time - initial_client_time;
	
	@warning_ignore("integer_division")
	var estimated_ping : int = RTT/2;
	ping_results.append(estimated_ping);
	if server_time > last_calculated_server_time:
		last_calculated_server_time = server_time;
		associated_client_time = current_client_time;
