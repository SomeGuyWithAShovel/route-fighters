extends Node2D
class_name Character

@onready var animated_sprite : AnimatedSprite2D = $"AnimatedSprite2D";
var current_move : MoveInformation :
	get = get_current_move,
	set = set_current_move;
	
var player_id : int;
var ping_calculator : PingCalculator = null;

func _ready() -> void:
	move_interrupted.connect(update_animated_sprite);
	
func get_absolute_frame_duration(anim_name : String, frame_index : int) -> float:
	var playing_speed : float = animated_sprite.get_playing_speed();
	var animation_fps : float = animated_sprite.sprite_frames.get_animation_speed(anim_name);
	var relative_frame_duration := animated_sprite.sprite_frames.get_frame_duration(anim_name, frame_index);
	var absolute_frame_duration : float = relative_frame_duration / (animation_fps * abs(playing_speed));
	return absolute_frame_duration;
	
func update_animated_sprite(_old_move : MoveInformation, new_move : MoveInformation) -> void:
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
	current_move = new_move;
