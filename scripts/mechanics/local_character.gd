extends Character
class_name LocalCharacter

# Les deux sont set par le coordinateur, pas touche !

signal input_move(move : Move.Kind);

var frames_in_air : int = 0;

# Jump a 30 frames
# Des frames 0 à 14, le personnage montera
# Des frames 15 à 29, le personnage descendra
var gravity_per_frame := Vector2(0, -1.0/14.5);

func _ready() -> void:
	super._ready();
	print("Indice du joueur : ", player_id);
	input_move.connect(on_input);

func set_current_move(new_move : MoveInformation) -> void:
	print("Local move, : ", Move.Kind.keys()[new_move]);
	super.set_current_move(new_move);

func create_move_info(move : Move.Kind) -> MoveInformation:
	var server_time := ping_calculator.get_server_time();
	var move_info := MoveInformation.new(global_position, server_time, move);
	return move_info;

func is_move_done(move : MoveInformation) -> bool:
	return ping_calculator.get_server_time() > move.server_time_started + Move.duration_in_frames(move.kind);

func input_changes_current_move(inputed_move : Move.Kind) -> bool:
	var should_move_be_considered := current_move.kind != inputed_move or Move.is_holdable(inputed_move);
	var is_current_changeable := Move.is_interruptible(current_move.kind) or is_move_done(current_move);
	return should_move_be_considered and is_current_changeable;


func on_input(move : Move.Kind) -> void:
	if input_changes_current_move(move):
		current_move = create_move_info(move);
	
func _physics_process(delta: float) -> void:
	position += delta*Move.position_delta(current_move.kind);
	if position.y > GlobalConstant.GROUND_Y:
		frames_in_air += 1;
	else:
		frames_in_air = 0;
	position += delta*gravity_per_frame;
	
	if position.y < GlobalConstant.GROUND_Y:
		position.y = GlobalConstant.GROUND_Y;

func _unhandled_input(input: InputEvent) -> void:
	var move := Move.Kind.NOTHING;
	
	if input.is_action_pressed("jump"):
		move = Move.Kind.JUMP
		
	if input.is_action_pressed("move_left"):
		if move == Move.Kind.JUMP:
			move = Move.Kind.JUMP_LEFT;
		else:
			move = Move.Kind.LEFT
	elif input.is_action_pressed("move_right"):
		if move == Move.Kind.JUMP:
			move = Move.Kind.JUMP_RIGHT
		else:
			move = Move.Kind.RIGHT;
	elif input.is_action_pressed("shoot"):
		move = Move.Kind.SHOOT
	elif input.is_action_pressed("kick"):
		move = Move.Kind.KICK
	elif input.is_action_pressed("punch"):
		move = Move.Kind.PUNCH
	
	input_move.emit(move);
