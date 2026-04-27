extends Node2D

@export_group("Local player")
@export var local_moves : Array[Move.Kind];
@export var local_position : Array[Vector2];
@export var local_start : int;

@export_group("Remote player")
@export var remote_moves : Array[Move.Kind];
@export var remote_positions : Array[Vector2];
@export var remote_start : int;

# Essayé pour 

func _ready() -> void:
	var local_action_buffer  := ActionBuffer.new(3);
	var remote_action_buffer := ActionBuffer.new(3);
	
	var local_t := local_start;
	
	var ggpo := GGPO.new();
	
	for i in range(len(local_moves)):
		var move := local_moves[i];
		var at := local_position[i];
		var length := Move.duration_in_frames(move);
		local_action_buffer.add_move(move, at, local_t);
		local_t += length;
		
	var remote_t := remote_start;
	
	for i in range(len(remote_moves)):
		var move := remote_moves[i];
		var at := remote_positions[i];
		var length := Move.duration_in_frames(move);
		remote_action_buffer.add_move(move, at, remote_t);
		remote_t += length;
		
	local_action_buffer.correct_actions(remote_action_buffer, local_t, ggpo);
	print("ok");
	return;
