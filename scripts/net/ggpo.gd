extends Node
class_name GGPO

func predict_move(action_buffer : ActionBuffer) -> Move.Kind:
	return action_buffer.get_last_move().kind;
