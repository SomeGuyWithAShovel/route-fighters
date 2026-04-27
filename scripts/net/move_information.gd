extends Object
class_name MoveInformation
	
# Envoyé sur le réseau dans un historique
	
var position : Vector2;
var server_time_started : int;
var kind : Move.Kind;

func _init(_position : Vector2, _server_time : int, _kind : Move.Kind) -> void:
	position = _position;
	server_time_started = _server_time;
	kind = _kind;

func is_approx_same(other : MoveInformation) -> bool:
	return (kind == other.kind
		and server_time_started == other.server_time_started
		and position.is_equal_approx(other.position));
