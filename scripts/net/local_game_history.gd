class_name NetLocalGameHistory
extends RefCounted

# sizeof(MoveInformation) ~= sizeof(Vector2 + int + Move.Kind) = 16 + 8 + 8 = 32 bits = 4 octets
#
# Un paquet UDP peut contenir 65507 octets au maximum
# 65507/8 = 16.376 MoveInformation
#
# En gros, on a de la marge, on va prendre une puissance de 2 assez grande
# 60 FPS 1024/60 >= 17 secondes
const MAX_MOVES_IN_UDP_PACKET := 1024;

var moves : Array[MoveInformation];
var server_time : int;
var player_id : int;


func _init(_player_id : int, _server_time : int, _action_buffer : ActionBuffer) -> void:
	server_time = _server_time;
	player_id = _player_id;
	
	moves.resize(len(_action_buffer));
	
	for i in range(len(_action_buffer.player_move_buffer)):
		var i_buffer = (i + _action_buffer.newest_frame) % len(_action_buffer.player_move_buffer);
		moves[i] = _action_buffer.player_move_buffer[i_buffer];

func to_player_input() -> ActionBuffer:
	# Que le buffer circulaire commence à partir de 0 n'est pas un pb, 
	# et ça permet de récupérer l'historique de cette façon
	return ActionBuffer.from_move_buffer(player_id, moves, 0);
