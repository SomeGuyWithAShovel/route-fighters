# @tool

class_name Character
extends Node2D

# dans la scène player, on a :
# Node2D                  <- ne possède pas de script DANS L'ÉDITEUR
#  L Player               <- possède ce script
#     L CollisionShape2D  
#     L AnimationPlayer   
#
# Node2D n'a pas de script dans la scène dans l'éditeur, mais un script lui est attaché
# à la construction d'un player (dans PlayersCoordinator), soit local_character.gd, soit remote_character.gd

@export var anim_sprite_scenes : Array[PackedScene] = [
	preload("res://scenes/visuals/ken.tscn"),
	preload("res://scenes/visuals/ryu.tscn"),
];

var animated_sprite : AnimatedSprite2D = null;

#region test_debug_animated_sprite
#
#@export_group("editor_anim_sprite_DEBUG_ONLY_RESET_BEFORE_START_OR_SAVE")
#
#@export_tool_button("set_host")
#var editor_set_host_var = editor_set_host;
#func editor_set_host() -> void :
	#print("editor_set_host");
	#editor_reset();
	#set_player_id(1);
	#return;
#
#@export_tool_button("set_remote")
#var editor_set_remote_var = editor_set_remote;
#func editor_set_remote() -> void :
	#print("editor_set_remote");
	#editor_reset();
	#set_player_id(2);
	#return;
#
#@export_tool_button("reset")
#var editor_reset_var = editor_reset;
#func editor_reset() -> void :
	#print("editor_reset");
	#if (animated_sprite == null) :
		#return;
	#animated_sprite.queue_free();
	#animated_sprite = null;
	#return;
#@export_group("")

#endregion

var current_move : MoveInformation = MoveInformation.new(Vector2.ZERO, 0, Move.Kind.NOTHING) :
	get = get_current_move,
	set = set_current_move;
	
var ping_calculator : PingCalculator = null;

#region player_init : id, sprite and transform
var player_id : int = 0;
func set_player_id(new_id : int) -> void :
	if (animated_sprite != null) :
		pass;
	var sprite_id : int = 0;
	if (new_id != 1) :
		sprite_id = 1;
	assert(anim_sprite_scenes.size() == 2);
	assert((sprite_id >= 0) && (sprite_id <= 1));
	var new_sprite_node : AnimatedSprite2D = anim_sprite_scenes[sprite_id].instantiate() as AnimatedSprite2D;
	assert(new_sprite_node != null);
	
	add_child(new_sprite_node);
	animated_sprite = new_sprite_node;
	return;

func init_player(new_id : int, start_pos : Transform2D) -> void :
	set_player_id(new_id);
	
	# see PlayersCoordinator::get_character_from_player comments
	var parent_node : Node2D = get_parent() as Node2D;
	assert(parent_node != null);
	parent_node.global_transform = start_pos;
	
	# print("init_player : sprite ", animated_sprite, " and transform ", global_transform);
	
	# moved from _ready()
	move_interrupted.connect(update_animated_sprite);
	animated_sprite.animation_finished.connect(func () : animated_sprite.play("idle"));
	return;

#endregion

func _ready() -> void:
	print("player._ready()");
	assert(anim_sprite_scenes.size() == 2);
	assert(anim_sprite_scenes[0] != null);
	assert(anim_sprite_scenes[1] != null);
	
	assert(current_move != null);
	return;

func get_absolute_frame_duration(anim_name : String, frame_index : int) -> float:
	var playing_speed : float = animated_sprite.get_playing_speed();
	var animation_fps : float = animated_sprite.sprite_frames.get_animation_speed(anim_name);
	var relative_frame_duration := animated_sprite.sprite_frames.get_frame_duration(anim_name, frame_index);
	var absolute_frame_duration : float = relative_frame_duration / (animation_fps * abs(playing_speed));
	return absolute_frame_duration;
	
func update_animated_sprite(_old_move : MoveInformation, new_move : MoveInformation) -> void:
	# Les moves holdables ne sont pas changés dans les sprites à chaque frame
	if (Move.is_holdable(new_move.kind)) : 
		return;
	
	var anim_name : String = Move.Kind.keys()[new_move.kind].to_lower;
	animated_sprite.play(anim_name);
	var current_time := ping_calculator.get_server_time();
	var animation_start := new_move.server_time_started;
	var seconds_to_catch_up_in_anim := float(current_time - animation_start) / 1000;
	
	var i := 0;
	while seconds_to_catch_up_in_anim - get_absolute_frame_duration(anim_name, i) > 0:
		seconds_to_catch_up_in_anim -= get_absolute_frame_duration(anim_name, i);
		i += 1;
		assert(i < animated_sprite.sprite_frames.get_frame_count(anim_name),
		 "Dernier move trop vieux pour la dernière frame");
			
	var progress := seconds_to_catch_up_in_anim / get_absolute_frame_duration(anim_name, i);
	animated_sprite.set_frame_and_progress(i, progress);
	
# Envoyé si le joueur se fait taper ou si GGPO change l'attaque du joueur distant
signal move_interrupted(old_move_info : MoveInformation, new_move_info : MoveInformation);

func get_current_move() -> MoveInformation:
	return current_move;
	
func set_current_move(new_move : MoveInformation) -> void:
	update_animated_sprite(current_move, new_move);
	current_move = new_move;
