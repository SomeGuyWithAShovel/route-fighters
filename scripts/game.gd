class_name GameNode
extends Node

signal on_ready();

@export var players_parent_node : Node2D = null;
@export var player_starting_nodes : Array[Node2D] = [null, null];
@export var countdown : GameCountdown = null;
@export var players_hud : Array[PlayerHUD];

func _ready() -> void :
	assert(countdown != null);
	
	init_players_coordinator();
	for node : Node2D in player_starting_nodes :
		node.hide();
		pass;
	
	assert(players_hud.size() == 2);
	for hud : PlayerHUD in players_hud :
		assert(hud != null);
		# the signal linked to on_player_joined() fire BEFORE this._ready()...
		# hud.player_quit();
		pass;
	return;

# the signal linked to on_player_joined() fire BEFORE this._ready()...
func _enter_tree() -> void :
	for hud : PlayerHUD in players_hud :
		hud.player_quit();
		pass;
	return;

func init_players_coordinator() -> void :
	GlobalCoordinator.players_coordinator.connect("player_created", on_player_joined);
	GlobalCoordinator.players_coordinator.connect("player_destroyed", on_player_left);
	GlobalCoordinator.players_coordinator.init_from_game_node(self);
	on_ready.emit(); # idk if here is good or not
	return;

func start_game() -> void :
	countdown.start();
	return;

func cancel_game() -> void :
	countdown.cancel_countdown();
	return;

func on_player_joined(player_id : int) -> void :
	# print("GAME::ON_PLAYER_JOINED");
	var player_hud_id : int = 0 if (player_id == 1) else 1;
	if (player_hud_id == 0) :
		players_hud[player_hud_id].set_layout_as_player_left();
		pass;
	else :
		players_hud[player_hud_id].set_layout_as_player_right();
		pass;
	players_hud[player_hud_id].player_joined();
	return;

func on_player_left(player_id : int) -> void :
	players_hud[0 if (player_id == 1) else 1].player_quit();
	return;
