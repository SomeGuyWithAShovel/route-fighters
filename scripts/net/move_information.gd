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
