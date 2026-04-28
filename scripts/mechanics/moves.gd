extends Node
class_name Move

enum Kind {
	# Ne pas envoyer NOTHING sur le réseau, 
	# C'est juste pour avoir une valeur par défaut dans le buffer de moves
	NOTHING = 0, 	
	LEFT,
	RIGHT,
	JUMP,
	JUMP_LEFT,
	JUMP_RIGHT,
	KICK,
	PUNCH,
	GUARD,
	SHOOT,
	HURT,
};

# Les moves holdables ne sont pas changé dans les sprites à chaque frame
# Ils sont envoyés à chaque frame d'exécution sur le serveur
static func is_holdable(move : Kind) -> bool:
	return (move == Kind.LEFT or move == Kind.RIGHT 
		or move == Kind.JUMP or move == Kind.JUMP_LEFT or move == Kind.JUMP_RIGHT);

# Les moves interruptibles peuvent à tout moment être remplacé par un autre
static func is_interruptible(move : Kind) -> bool:
	return (move == Kind.JUMP or move == Kind.JUMP_LEFT or move == Kind.JUMP_RIGHT);

# À multiplier par TARGET_DELTA_TIME
static func position_delta(_move : Kind) -> Vector2:
	match _move:
		Kind.LEFT:
			return Vector2.LEFT;
		Kind.RIGHT:
			return Vector2.RIGHT;
		Kind.JUMP:
			return Vector2.UP;
		Kind.JUMP_LEFT:
			return Vector2(-1, 1);
		Kind.JUMP_RIGHT:
			return Vector2(1, 1);
		_:
			return Vector2.ZERO;
			
# Durée en frames de simulation, ne coincide pas toujours avec les frames affichées
static func duration_in_frames(_move : Kind) -> int:
	match _move:
		Kind.NOTHING:
			return 5*0;
		Kind.LEFT:
			return 5*0;
		Kind.RIGHT:
			return 5*0;
		Kind.JUMP:
			return 5*6;
		Kind.JUMP_LEFT:
			return 5*6;
		Kind.JUMP_RIGHT:
			return 5*6;
		Kind.KICK:
			return 5*5;
		Kind.PUNCH:
			return 5*3;
		Kind.GUARD:
			return 5*2;
		Kind.SHOOT:
			return 5*4;
		Kind.HURT:
			return 5*4;
	
	assert(not Move.Kind.has(_move), "ERREUR PROGRAMMEUR : La durée du move n'est pas donné dans moves.gd:duration_in_frames" % _move);
	assert(Move.Kind.has(_move), "Move inconnu : %d" % _move);
	return -1;

# Tout ce qui est spritesheet, durée des moves, etc. devrait être ici.
