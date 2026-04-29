class_name MainMenu
extends Control

@export
var GameScene : PackedScene = null;

func _ready() -> void :
	
	assert(GameScene != null);
	
	if (GlobalCoordinator.has_cmd_args) :
		game_started();
		pass;
	return;

func on_server_created(_our_player_id : int) -> void :
	game_started();
	return;

func on_server_joined(_remote_player_id : int) -> void :
	game_started();
	return;

func game_started() -> void :
	var game_node : Node = GameScene.instantiate();
	assert(game_node != null);
	get_parent().add_child.call_deferred(game_node);
	queue_free();
	return;

func _on_btn_host_pressed() -> void :
	GlobalCoordinator.multiplayer_api_coordinator.create_server();
	return;


func _on_btn_join_pressed() -> void :
	GlobalCoordinator.multiplayer_api_coordinator.join_server();
	return;


func _on_btn_quit_pressed() -> void :
	get_tree().quit();
	return;
