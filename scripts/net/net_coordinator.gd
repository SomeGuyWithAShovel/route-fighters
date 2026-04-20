extends Node
class_name NetCoordinator

const MAX_NUMBER_PLAYERS : int = 2;
const DEFAULT_PORT : int = 1050;

signal player_joined(player_id : int);
signal player_quit(player_id : int);

var ping_calculator : PingCalculator = null;

func create_server() -> void:
	var peer := ENetMultiplayerPeer.new();
	var error := peer.create_server(DEFAULT_PORT, MAX_NUMBER_PLAYERS);
	if error != OK:
		printerr("Could not create server");
		return;
	multiplayer.multiplayer_peer = peer;
	multiplayer.peer_connected.connect(
		func (player_id : int) : player_joined.emit(player_id)
	);
	multiplayer.peer_disconnected.connect(
		func (player_id : int) : player_quit.emit(player_id)
	)
	
func join_server(ip_address : String = "127.0.0.1") -> void:
	var peer := ENetMultiplayerPeer.new();
	peer.create_client(ip_address, DEFAULT_PORT);
	multiplayer.multiplayer_peer = peer;
	ping_calculator = PingCalculator.new();
	
func terminate_connection() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new();
	
@rpc("authority", "call_remote", "unreliable")
func Server_player_move(character)
	
func local_player_move(character : Character, move : Move.Kind) -> void:
	
