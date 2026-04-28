extends Node
class_name Move

enum Kind {
	# Ne pas envoyer NOTHING sur le réseau, 
	# C'est juste pour avoir une valeur par défaut dans le buffer de moves
	NOTHING = 0, 	
	LEFT,
	RIGHT,
	JUMP,
	KICK,
	PUNCH,
	GUARD,
	SHOOT,
	HURT,
};

# À multiplier par TARGET_DELTA_TIME
static func position_delta(_move : Kind) -> Vector2:
	match _move:
		Kind.LEFT:
			return Vector2.LEFT;
		Kind.RIGHT:
			return Vector2.RIGHT;
		_:
			return Vector2.ZERO;

static func duration_in_frames(_move : Kind) -> int:
	# Durées à modifier, j'ai juste besoin de quelque chose pour tester -Matéu
	match _move:
		Kind.NOTHING:
			return 0;
		Kind.LEFT:
			return 1;
		Kind.RIGHT:
			return 1;
		Kind.JUMP:
			return 24;
		Kind.KICK:
			return 16;
		Kind.PUNCH:
			return 12;
		Kind.GUARD:
			return 4;
		Kind.SHOOT:
			return 8;
	
	assert(not Move.Kind.has(_move), "ERREUR PROGRAMMEUR : La durée du move n'est pas donné dans moves.gd:duration_in_frames" % _move);
	assert(Move.Kind.has(_move), "Move inconnu : %d" % _move);
	return -1;

# Tout ce qui est spritesheet, durée des moves, etc. devrait être ici.
