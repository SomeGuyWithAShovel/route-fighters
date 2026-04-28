extends Character
class_name RemoteCharacter

func set_current_move(new_move : MoveInformation) -> void:
	print("Remote move, : ", Move.Kind.keys()[new_move.kind]);
	if not current_move.is_approx_same(new_move):
		# Se connecter pour modifier l'affichage et/ou des statistiques de mauvaises prédictions
		move_interrupted.emit(current_move, new_move);
		super.set_current_move(new_move);
