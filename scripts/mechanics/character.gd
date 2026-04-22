extends Node
class_name Character

var player_id; # Set par le coordinateur, pas touche !

# Code pour la gestion des inputs du personnage

signal input_move(character : Character, move : Move.Kind);

func _ready() -> void:
	print("Indice du joueur : ", player_id);

func show_move(_move : Move.Kind, _frame : int) -> void:
	# TODO
	return;
	
func is_doing_move() -> bool:
	# TODO
	return false;
	
func _input(__input : InputEvent) -> void:
	
	# TODO : Traduire input en Move et emit le bon signal
	
	# On peut pas faire 2 moves en même temps
	if is_doing_move(): 
		return;
	
	input_move.emit(self, Move.Kind.LEFT);
