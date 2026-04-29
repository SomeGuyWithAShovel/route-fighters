class_name LocalCharacter
extends Node2D

var char_node : Character = null;

# Les deux sont set par le coordinateur, pas touche !

signal input_move(move : Move.Kind);

var frames_in_air : int = 0;

# Jump a 30 frames
# Des frames 0 à 14, le personnage montera
# Des frames 15 à 29, le personnage descendra
var gravity_per_frame := Vector2(0, -1.0/14.5);

# vu qu'on ne fait qu'attacher ce script au runtime, à une node déjà existante,
# _ready() ne semble être jamais appelé
func init() -> void  :
	print("local_character.gd::_ready()");
	char_node = get_child(0) as Character;
	assert(char_node != null);
	
	set_process(true);
	set_physics_process(true);
	
	
	print("Indice du joueur : ", char_node.player_id);
	input_move.connect(on_input);

func set_current_move(new_move : MoveInformation) -> void:
	print("Local move, : ", Move.Kind.keys()[new_move]);
	char_node.set_current_move(new_move);

func create_move_info(move : Move.Kind) -> MoveInformation:
	var server_time := char_node.ping_calculator.get_server_time();
	var move_info := MoveInformation.new(global_position, server_time, move);
	return move_info;

func is_move_done(move : MoveInformation) -> bool:
	return char_node.ping_calculator.get_server_time() > move.server_time_started + Move.duration_in_frames(move.kind);

func input_changes_current_move(inputed_move : Move.Kind) -> bool:
	var should_move_be_considered := char_node.current_move.kind != inputed_move or Move.is_holdable(inputed_move);
	var is_current_changeable := Move.is_interruptible(char_node.current_move.kind) or is_move_done(char_node.current_move);
	return should_move_be_considered and is_current_changeable;


func on_input(move : Move.Kind) -> void:
	if input_changes_current_move(move):
		char_node.current_move = create_move_info(move);
	
func _physics_process(delta: float) -> void:
	# print("local_char : ", char_node.current_move.kind);
	
	position += delta*Move.position_delta(char_node.current_move.kind);
	if position.y > GlobalConstant.GROUND_Y:
		frames_in_air += 1;
	else:
		frames_in_air = 0;
	position += delta*gravity_per_frame;
	
	if position.y < GlobalConstant.GROUND_Y:
		position.y = GlobalConstant.GROUND_Y;

# should be _unhandled_input, but it doesn't work
# _input doesn't work either.........
func _input(input: InputEvent) -> void :
	print("ADZA?POZD?PANZD");
	var move := Move.Kind.NOTHING;
	
	if input.is_action_pressed("jump") :
		move = Move.Kind.JUMP;
		pass;
		
	if input.is_action_pressed("move_left") :
		if (move == Move.Kind.JUMP) :
			move = Move.Kind.JUMP_LEFT;
			pass;
		else:
			move = Move.Kind.LEFT;
			pass;
	elif input.is_action_pressed("move_right") :
		if (move == Move.Kind.JUMP) :
			move = Move.Kind.JUMP_RIGHT;
			pass;
		else:
			move = Move.Kind.RIGHT;
			pass;
	elif input.is_action_pressed("shoot") :
		move = Move.Kind.SHOOT;
		pass;
	elif input.is_action_pressed("kick") :
		move = Move.Kind.KICK;
		pass;
	elif input.is_action_pressed("punch") :
		move = Move.Kind.PUNCH;
		pass;
	
	print_move_kind(move);
	input_move.emit(move);
	return;

func print_move_kind(_move : Move.Kind) -> void :
	var msg : String;
	match _move:
		Move.Kind.LEFT:
			msg = "LEFT";
		Move.Kind.RIGHT:
			msg = "RIGHT";
		Move.Kind.JUMP:
			msg = "UP";
		Move.Kind.JUMP_LEFT:
			msg = "JUMP_LEFT";
		Move.Kind.JUMP_RIGHT:
			msg = "JUMP_RIGHT";
		_:
			msg = "NOTHING";
	print(msg);
	return;
