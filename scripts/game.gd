class_name GameNode
extends Node

signal on_ready();

@export var players_parent_node : Node2D;
@export var player_starting_nodes : Array[Node2D];

func _ready() -> void :
	for node : Node2D in player_starting_nodes :
		node.hide();
		pass;
	return;

func init_players_coordinator() -> void :
	GlobalCoordinator.players_coordinator.init_from_game_node(self);
	
	on_ready.emit(); # idk if here is good or not
	return;
