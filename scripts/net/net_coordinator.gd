extends Node
class_name NetCoordinator

const MAX_NUMBER_PLAYERS : int = 2;
const DEFAULT_PORT : int = 1050;

signal player_joined(player_id : int);
signal player_quit(player_id : int);

var ping_calculator : PingCalculator = null;

var local_player_input : ActionBuffer;
# C'est pas beaucoup plus dur ni lourd d'implémenter pour n joueurs, même si on en a que 2
# dictionnaire player_id -> action_buffer
var other_player_inputs : Dictionary[int, ActionBuffer];

var registered_player_ids : Array[int];

func create_server() -> void:
	var peer := ENetMultiplayerPeer.new();
	var error := peer.create_server(DEFAULT_PORT, MAX_NUMBER_PLAYERS);
	if error != OK:
		printerr("Could not create server");
		return;
	multiplayer.multiplayer_peer = peer;
	multiplayer.peer_connected.connect(on_player_joined);
	multiplayer.peer_disconnected.connect(on_player_quit);
	
func join_server(ip_address : String = "127.0.0.1") -> void:
	var peer := ENetMultiplayerPeer.new();
	peer.create_client(ip_address, DEFAULT_PORT);
	multiplayer.multiplayer_peer = peer;
	ping_calculator = PingCalculator.new();
	local_player_input = ActionBuffer.new();
	
func terminate_connection() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new();
	
func on_player_joined(player_id : int) -> void:
	other_player_inputs[player_id] = ActionBuffer.new();
	player_joined.emit(player_id);
	
func on_player_quit(player_id : int) -> void:
	player_quit.emit(player_id);
	
func local_player_move(character : Character, move : Move.Kind) -> void:
	local_player_input.add_move(move, character.global_position);
	var server_time := ping_calculator.get_server_time();
	var local_player_id := multiplayer.get_unique_id();
	var net_history := NetLocalGameHistory.from_player_input(
		local_player_id, server_time, local_player_input
	);
	Server_player_move.rpc_id(1, net_history);
	
@rpc("any_peer", "call_remote", "unreliable")
func Server_player_move(history : NetLocalGameHistory) -> void:
	var sender := multiplayer.get_remote_sender_id();
	for id in multiplayer.get_peers():
		if id != sender:
			Client_recieve_player_move.rpc(sender, history);

@rpc("authority", "call_remote", "unreliable")
func Client_recieve_player_move(history : NetLocalGameHistory) -> void:
	var remote_player_input := history.to_player_input();
	other_player_inputs[history.player_id].correct_actions(remote_player_input);
