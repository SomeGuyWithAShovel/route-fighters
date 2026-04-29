# AUTOLOAD
class_name GlobalCoordinatorNode
extends Node

var multiplayer_api_coordinator : MultiplayerAPICoordinator;
var players_coordinator : PlayersCoordinator;

func init_coordinators_vars() -> bool :
	multiplayer_api_coordinator = $MultiplayerAPICoordinator;
	players_coordinator = $PlayersCoordinator;
	return true;

# called after init_coordinators_vars() !
func init_coordinators() -> bool :
	# we probably should use the editor signal connection editor instead of all these lines
	
	# T ODO : we need to do some inits before creating players
	# so connect these signals to something that does these inits and then create players
	# FIX : create_player now awaits for the inits
	
	multiplayer_api_coordinator.server_on_server_created.connect(players_coordinator.create_local_player);
	multiplayer_api_coordinator.client_on_server_joined.connect(players_coordinator.create_local_player);
	
	multiplayer_api_coordinator.server_on_player_joined.connect(players_coordinator.create_remote_player);
	
	multiplayer_api_coordinator.server_on_player_quit.connect(players_coordinator.remove_player);
	
	
	# When a server is created or joined : notify the main menu (so it can destroy itself)
	var main_node : MainNode = get_node("/root/Main") as MainNode;
	assert(main_node != null);
	multiplayer_api_coordinator.server_on_server_created.connect(main_node.menu_node.on_server_created);
	multiplayer_api_coordinator.client_on_server_joined.connect(main_node.menu_node.on_server_joined);
	
	return true;


var has_cmd_args : bool = false;
func read_cmd_args() -> void :
	const cmds : Array[String] = [
		"--server",
		"--client"
	];
	var instance_args = OS.get_cmdline_args();
	print("instance_args : ", instance_args)
	for arg in instance_args:
		if arg.begins_with(cmds[0]) :
			print("read ", cmds[0], " from command-line args");
			
			has_cmd_args = true;
			multiplayer_api_coordinator.create_server();
			pass;
		if arg.begins_with(cmds[1]) :
			print("read ", cmds[1], " from command-line args");
			
			has_cmd_args = true;
			multiplayer_api_coordinator.join_server();
			pass;
		pass;
	return;


func _ready() -> void :
	if (init_coordinators_vars() == false) :
		assert(false);
		return;
	if (init_coordinators() == false) :
		assert(false);
		return;
	read_cmd_args();
	return;
