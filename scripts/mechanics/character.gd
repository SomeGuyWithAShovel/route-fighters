extends Node
class_name Character

var player_id; # Set par le coordinateur, pas touche

# Code pour la gestion des inputs du personnage

signal input_move(character : Character, move : Move.Kind);

func _ready() -> void:
	print("Indice du joueur : ", player_index);

# warning-ignore:unused_argument 
@warning_ignore("unused_parameter")
func show_move(move : Move.Kind, frame : int) -> void:
	return;
	
func is_doing_move() -> bool:
	return false;
	
@warning_ignore("unused_parameter")
func _input(input : InputEvent) -> void:
	# On peut pas faire 2 moves en même temps
	if is_doing_move(): 
		return;
	
	input_move.emit(self, Move.Kind.LEFT);
