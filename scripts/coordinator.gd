extends Node

var players : Array[Character] = [];
var net_coordinator : NetCoordinator;

func _ready() -> void:
	net_coordinator.player_joined.connect(add_player);
	net_coordinator.player_quit.connect(warn_players);
	
func add_player(player_id : int) -> void:
	var new_player = Character.new();
	new_player.player_index = player_id;
	
	# TODO: Set sa position, etc..
	
	new_player.input_move.connect(net_coordinator.local_player_move);
	players.append(new_player);
	
@rpc("any_peer", "call_remote", "reliable")
func warn_players() -> void:
	printerr("Other player left !");
	await get_tree().create_timer(1.0).timeout;
	get_tree().quit();
