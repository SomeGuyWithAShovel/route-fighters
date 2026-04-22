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
	GUARD
};

static func duration_in_frames(_move : Kind) -> int:
	# TODO
	return 42;

# Tout ce qui est spritesheet, durée des moves, etc. devrait être ici.
