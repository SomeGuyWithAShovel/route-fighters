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
	multiplayer_api_coordinator.server_on_server_created.connect(players_coordinator.create_local_player);
	multiplayer_api_coordinator.server_on_player_joined.connect(players_coordinator.create_remote_player);
	multiplayer_api_coordinator.server_on_player_quit.connect(players_coordinator.warn_players);
	
	multiplayer_api_coordinator.client_on_server_joined.connect(players_coordinator.create_local_player);
	return true;

func read_cmd_args() -> void :
	var instance_args = OS.get_cmdline_args();
	print("instance_args : ", instance_args)
	for arg in instance_args:
		if arg.begins_with("--server") :
			print("INIT AS SERVER");
			pass;
		if arg.begins_with("--client") :
			print("INIT AS CLIENT");
			pass;
	pass;


func _ready() -> void :
	if (init_coordinators_vars() == false) :
		assert(false);
		return;
	if (init_coordinators() == false) :
		assert(false);
		return;
	read_cmd_args();
	return;
