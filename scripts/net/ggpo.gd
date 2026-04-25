extends Node
class_name GGPO

# Un pour chaque joueur adverse
@onready var character : Character;

func predict_move(action_buffer : ActionBuffer) -> Move.Kind:
	return action_buffer.get_last_move();
