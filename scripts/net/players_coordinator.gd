class_name PlayersCoordinator
extends Node

@export_group("Player Scenes")
@export var local_player_scene : PackedScene;
@export var remote_player_scene : PackedScene;

var local_player_script  : Script = preload("res://scripts/mechanics/local_character.gd");
var remote_player_script : Script = preload("res://scripts/mechanics/remote_character.gd");

var player_starting_positions : Array[Node2D];
var players_node_parent : Node = null;

var players : Dictionary[int, Character] = {};
# we should use somewhere our own system of player ids,
# because server is player 1 and client is player 992135560 (it's random)
# I don't think we want an array of size 992135560 just for 2 elements

var ping_calculator : PingCalculator = null;

var local_player_id : int;
var local_action_buffer : ActionBuffer;
var ggpo : GGPO;

# C'est pas beaucoup plus dur ni lourd d'implémenter pour n joueurs, même si on en a que 2
# dictionnaire player_id -> action_buffer
var other_player_inputs : Dictionary[int, ActionBuffer];

func init_from_game_node(game_node : GameNode) -> void :
	assert(game_node != null);
	
	assert(game_node.player_starting_positions.size() == 2);
	assert(game_node.player_starting_positions[0] != null);
	assert(game_node.player_starting_positions[1] != null);
	player_starting_positions = game_node.player_starting_positions;
	
	assert(game_node.player)
	return;

func create_local_player(player_id : int) -> void :
	assert(local_player_scene != null);
	var new_player : Node = local_player_scene.instantiate();
	assert(new_player != null);
	
	local_player_scene.set_script(local_player_script);
	
	new_player.player_id = player_id;
	new_player.ping_calculator = ping_calculator;
	local_player_id = player_id;
	
	new_player.transform = player_starting_positions[0].transform;
	
	assert(players_node_parent != null);
	players_node_parent.add_child(new_player);
	
	new_player.input_move.connect(local_player_moved);
	players[player_id] = new_player;
	
	return;

func create_remote_player(player_id : int) -> void :
	assert(remote_player_scene != null);
	var new_player = remote_player_scene.instantiate();
	new_player.set_script(remote_player_script);
	new_player.player_id = player_id;
	
	# TODO: Set sa position, etc..
	assert(players_node_parent != null);
	players_node_parent.add_child(new_player);
	players[player_id] = new_player;
	return;
	

@rpc("any_peer", "call_remote", "reliable")
func warn_players() -> void:
	printerr("Other player left !");
	# await get_tree().create_timer(1.0).timeout;
	# get_tree().quit();
	return;


func local_player_moved(local_player : LocalCharacter, move : Move.Kind) -> void :
	if move == Move.Kind.NOTHING:
		return;
		
	var server_time := ping_calculator.get_server_time();
	local_action_buffer.add_move(move, local_player.global_position, server_time);
	var net_history := NetLocalGameHistory.new(
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
	var server_time := ping_calculator.get_server_time();
	other_player_inputs[history.player_id].correct_actions(remote_player_input, server_time, ggpo);
	other_player_inputs[history.player_id]
	players[history.player_id].set_current_move(corrected_move);
