extends Node

# Un pour chaque joueur adverse
@onready var character : Character;

func predict_move() -> Move.Kind:
	return Move.Kind.NOTHING;
