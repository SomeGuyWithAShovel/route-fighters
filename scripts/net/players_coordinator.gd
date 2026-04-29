class_name PlayersCoordinator
extends Node


signal on_init();
var has_been_init : bool = false;

@export_group("Player Scene")
@export var player_scene : PackedScene;

var local_player_script  : Script = preload("res://scripts/mechanics/local_character.gd");
var remote_player_script : Script = preload("res://scripts/mechanics/remote_character.gd");

var player_starting_positions : Array[Transform2D];
var players_node_parent : Node = null;

var players : Dictionary[int, Node2D] = {};
# because server is player 1 and client is player 992135560 (it's random)
# I don't think we want an array of size 992135560 just for 2 elements.
# That's why it's a Dictionary[int, T] and not an Array[T]

var ping_calculator : PingCalculator = null;

var local_player_id : int;
var local_action_buffer : ActionBuffer;
var local_action_buffer_last_time_received : float;
var ggpo : GGPO;

# C'est pas beaucoup plus dur ni lourd d'implémenter pour n joueurs, même si on en a que 2
# dictionnaire player_id -> action_buffer
var other_player_inputs : Dictionary[int, ActionBuffer];

var on_game_ready : Callable;

func init_from_game_node(game_node : GameNode) -> void :
	assert(game_node != null);
	
	assert(game_node.player_starting_nodes.size() == 2);
	assert(game_node.player_starting_nodes[0] != null);
	assert(game_node.player_starting_nodes[1] != null);
	
	player_starting_positions.resize(2);
	player_starting_positions[0] = game_node.player_starting_nodes[0].global_transform;
	player_starting_positions[1] = game_node.player_starting_nodes[1].global_transform;
	
	assert(game_node.players_parent_node != null);
	players_node_parent = game_node.players_parent_node;
	
	on_game_ready = game_node.start_game;
	
	has_been_init = true;
	on_init.emit();
	return;

# I didn't fully understood what you did, so I kept as it was :
# a Node2D scene root on which we attach the script local_player or remote_player at runtime,
# with a Character child node that is common between local and remote
#
# this function gets the Character child node from the Node2D scene root
func get_character_from_player(player_node : Node2D) -> Character :
	if (player_node == null) :
		return null;
	return (player_node.get_child(0) as Character);

# common between local and remote player
func create_player(player_id : int) -> Node2D :
	if (has_been_init == false) :
		print("create_player : await start");
		await on_init;
		print("create_player : await end");
		pass;
	
	var pl_start : Transform2D = player_starting_positions[1];
	if (player_id == 1) :
		pl_start =  player_starting_positions[0];
		pass;
	
	assert(player_scene != null);
	var new_player : Node = player_scene.instantiate();
	assert(new_player != null);
	assert(players_node_parent != null);
	players_node_parent.add_child(new_player);
	
	players[player_id] = new_player;
	
	var char_node : Character = get_character_from_player(new_player);
	assert(char_node != null);
	char_node.init_player(player_id, pl_start);
	
	return new_player;

func create_local_player(player_id : int) -> void :
	var new_player : Node = await create_player(player_id);
	assert(new_player != null);
	
	local_player_id = player_id;
	# new_player.set_script(local_player_script);
	# new_player.ping_calculator = ping_calculator;
	# new_player.input_move.connect(local_player_moved);
	
	print("local_player created (id:", player_id, ")");
	
	check_if_game_ready();
	return;

func create_remote_player(player_id : int) -> void :
	var new_player : Node = await create_player(player_id);
	assert(new_player != null);
	
	#new_player.set_script(remote_player_script);
	
	print("remote_player created (id:", player_id, ")");
	
	check_if_game_ready();
	return;

func check_if_game_ready() -> void :
	if (players.size() >= 2) :
		on_game_ready.call();
	return;

func remove_player(player_id : int) -> void :
	var player_node : Node2D = players.get(player_id);
	if (player_node == null) :
		print("PlayersCoordinator::remove_player(", player_id, ") : player_id wasn't in the players dictionary");
		return;
	
	player_node.queue_free();
	players.erase(player_id);
	print("removed player ", player_id);
	return;

@rpc("any_peer", "call_remote", "reliable")
func warn_players() -> void:
	printerr("Other player left !");
	# await get_tree().create_timer(1.0).timeout;
	# get_tree().quit();
	return;


func local_player_moved(local_player : LocalCharacter, move : Move.Kind) -> void :
	if (move == Move.Kind.NOTHING):
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
	var corrected_move := other_player_inputs[history.player_id].correct_actions(remote_player_input, server_time, ggpo);
	players[history.player_id].set_current_move(corrected_move);
