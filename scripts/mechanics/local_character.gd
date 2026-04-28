extends Character
class_name LocalCharacter

# Les deux sont set par le coordinateur, pas touche !

signal input_move(move : Move.Kind);

func _ready() -> void:
	super._ready();
	print("Indice du joueur : ", player_id);
	input_move.connect(on_input);

func set_current_move(move : MoveInformation) -> void:
	print("Local move, : ", Move.Kind.find_key(move.kind));
	current_move = move;

func create_move_info(move : Move.Kind) -> MoveInformation:
	var server_time := ping_calculator.get_server_time();
	var move_info := MoveInformation.new(global_position, server_time, move);
	return move_info;

func on_input(move : Move.Kind) -> void:
	current_move = create_move_info(move);
	
func _physics_process(delta: float) -> void:
	position += delta*Move.position_delta(current_move.kind);

func hit() -> void:
	var old := current_move;
	input_move.emit(self, Move.Kind.HURT);
	move_interrupted.emit(self, old, current_move);

func _unhandled_input(input: InputEvent) -> void:
	var move := Move.Kind.NOTHING;
	if input.is_action_pressed("move_left"):
		move = Move.Kind.LEFT
	elif input.is_action_pressed("move_right"):
		move = Move.Kind.RIGHT
	elif input.is_action_pressed("jump"):
		move = Move.Kind.JUMP
	elif input.is_action_pressed("shoot"):
		move = Move.Kind.SHOOT
	elif input.is_action_pressed("kick"):
		move = Move.Kind.KICK
	elif input.is_action_pressed("punch"):
		move = Move.Kind.PUNCH
	
	input.emit(move);
