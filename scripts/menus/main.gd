class_name MainNode
extends Node

@export
var game_scene : PackedScene;

@export var menu_node : MainMenu;

func move_to_game() -> void :
	
	assert(game_scene != null);
	if (menu_node != null) :
		var game_node : Node = game_scene.instantiate();
		add_child(game_node);
		menu_node.game_started();
		pass;
	return;
