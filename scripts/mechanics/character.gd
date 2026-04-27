extends Node2D
class_name Character

var player_id : int; # Set par le coordinateur, pas touche !
var ping_calculator : PingCalculator;

# Code pour la gestion des inputs du personnage

signal input_move(character : Character, move : Move.Kind);
signal move_prediction_is_different(character : Character, old_move_info : MoveInformation, new_move_info : MoveInformation);


var _current_move : MoveInformation;
var current_move : MoveInformation :
	get:
		return _current_move;
	set(new_move):
		if not _current_move.is_approx_same(new_move):
			# Se connecter pour modifier l'affichage et/ou des statistiques de mauvaises prédictions
			move_prediction_is_different.emit(self, _current_move, new_move);
			_current_move = new_move;

func local_set_current_move(_character : Character, move : Move.Kind) -> void:
	var server_time := ping_calculator.get_server_time();
	var move_info := MoveInformation.new(global_position, server_time, move);
	set_current_move(move_info);

func _ready() -> void:
	print("Indice du joueur : ", player_id);
	input_move.connect(local_set_current_move);

func show_move(_move : Move.Kind, _frame : int) -> void:
	# TODO
	return;
	
func is_doing_move() -> bool:
	# TODO
	return false;
	
func set_current_move(move : MoveInformation) -> void:
	_current_move = move;

func _input(__input : InputEvent) -> void:
	
	# TODO : Traduire input en Move et emit le bon signal
	
	# On peut pas faire 2 moves en même temps
	if is_doing_move(): 
		return;
	
	input_move.emit(self, Move.Kind.LEFT);
