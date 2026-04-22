class_name PlayersCoordinator
extends Node

@export
var local_player_scene : PackedScene;
var remote_player_scene : PackedScene;

var players : Array[Character] = [];

var ping_calculator : PingCalculator = null;

var local_player_id : int;
var local_action_buffer : ActionBuffer;

# C'est pas beaucoup plus dur ni lourd d'implémenter pour n joueurs, même si on en a que 2
# dictionnaire player_id -> action_buffer
var other_player_inputs : Dictionary[int, ActionBuffer];

func create_local_player(player_id : int) -> void :
	assert(local_player_scene != null);
	var new_player = local_player_scene.instantiate();
	new_player.player_index = player_id;
	local_player_id = player_id;
	
	# TODO: Set sa position, etc..
	# add to tree
	new_player.input_move.connect(local_player_moved);
	players.append(new_player);
	return;

func create_remote_player(player_id : int) -> void :
	assert(remote_player_scene != null);
	var new_player = remote_player_scene.instantiate();
	new_player.player_id = player_id;
	
	# TODO: Set sa position, etc..
	# add to tree
	players.append(new_player);
	return;
	

@rpc("any_peer", "call_remote", "reliable")
func warn_players() -> void:
	printerr("Other player left !");
	# await get_tree().create_timer(1.0).timeout;
	# get_tree().quit();
	return;


func local_player_moved(local_player : Character, move : Move.Kind) -> void :
	local_action_buffer.add_move(move, local_player.global_position);
	var server_time := ping_calculator.get_server_time();
	var net_history := NetLocalGameHistory.from_player_input(
		local_player.player_id, 
		server_time, 
		local_action_buffer
	);
	
	Server_player_move.rpc_id(1, net_history);
	return;

@rpc("any_peer", "call_remote", "unreliable")
func Server_player_move(history : NetLocalGameHistory) -> void:
	var sender : int = local_player_id;
	var all_player_ids : PackedInt32Array = GlobalCoordinator.multiplayer_api_coordinator.get_all_player_ids();
	for id in all_player_ids:
		if id != sender:
			Client_receive_player_move.rpc(sender, history);

@rpc("authority", "call_remote", "unreliable")
func Client_receive_player_move(history : NetLocalGameHistory) -> void:
	var remote_player_input := history.to_player_input();
	other_player_inputs[history.player_id].correct_actions(remote_player_input);
