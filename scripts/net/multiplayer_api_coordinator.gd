class_name MultiplayerAPICoordinator
extends Node

const MAX_NUMBER_PLAYERS : int = 2;
const DEFAULT_PORT : int = 1050;

signal server_on_server_created(our_player_id : int);
signal server_on_player_joined(player_id : int);
signal server_on_player_quit(player_id : int);

signal client_on_server_joined(our_player_id : int);
signal client_on_server_join_failed();
signal client_on_server_stop();

var is_in_a_game : bool = false;

@onready
var multiplayer_api : MultiplayerAPI = multiplayer; # Node.multiplayer

func _ready() -> void :
	
	# server signals
	multiplayer_api.peer_connected.connect(_server_player_joined);
	multiplayer_api.peer_disconnected.connect(_server_player_quit);
	
	# client signals
	multiplayer_api.connected_to_server.connect(_client_connected);
	multiplayer_api.connection_failed.connect(_client_connection_failed);
	multiplayer_api.server_disconnected.connect(_client_server_disconnected);
	
	return;

func create_server() -> void :
	var peer := ENetMultiplayerPeer.new();
	var error := peer.create_server(DEFAULT_PORT, MAX_NUMBER_PLAYERS);
	if error != OK:
		printerr("MultiplayerAPICoordinator : Could not create server (error ", error, ")");
		return;
	print("MultiplayerAPICoordinator : Server created (", DEFAULT_PORT, ")");
	multiplayer_api.multiplayer_peer = peer;
	
	var our_player_id : int = multiplayer_api.get_unique_id();
	is_in_a_game = true;
	server_on_server_created.emit(our_player_id);
	return;

#region server_signals

func _server_player_joined(player_id : int) -> void :
	# other_player_inputs[player_id] = ActionBuffer.new();
	print("MultiplayerAPICoordinator : player ", player_id, " joined");
	server_on_player_joined.emit(player_id);
	return;

func _server_player_quit(player_id : int) -> void :
	print("MultiplayerAPICoordinator : player ", player_id, " quit");
	# other_player_inputs[player_id] = null;
	server_on_player_quit.emit(player_id);
	return;

#endregion

func join_server(ip_address : String = "127.0.0.1") -> void :
	var peer := ENetMultiplayerPeer.new();
	var error := peer.create_client(ip_address, DEFAULT_PORT);
	if error != OK:
		printerr("Could not join server \"", ip_address, "\" (error ", error, ")");
		return;
	print("MultiplayerAPICoordinator : client joined (", ip_address, ")");
	multiplayer_api.multiplayer_peer = peer;
	return;

#region client_signals

func _client_connected() -> void :
	var our_player_id : int = multiplayer_api.get_unique_id();
	print("MultiplayerAPICoordinator : client connected (player_id ", our_player_id, ")");
	is_in_a_game = true;
	client_on_server_joined.emit(our_player_id);
	return;

func _client_connection_failed() -> void :
	print("MultiplayerAPICoordinator : client connection failed");
	is_in_a_game = false;
	client_on_server_join_failed.emit();
	_terminate_connection();
	return;

func _client_server_disconnected() -> void :
	print("MultiplayerAPICoordinator : client disconnected because server disconnected");
	is_in_a_game = false;
	client_on_server_stop.emit();
	_terminate_connection();
	return;

#endregion

func _terminate_connection() -> void :
	print("MultiplayerAPICoordinator : multiplayer_peer set to Offline");
	is_in_a_game = false;
	# MultiplayerPeer is RefCounted : no need to free the old one
	multiplayer_api.multiplayer_peer = OfflineMultiplayerPeer.new();
	return;

func get_all_player_ids() -> PackedInt32Array :
	return multiplayer_api.get_peers();
