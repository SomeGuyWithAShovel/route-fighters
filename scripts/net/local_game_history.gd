class_name NetLocalGameHistory
extends RefCounted

# TODO : L'array action_buffer à couper de sorte à ce que ça rentre sur le réseau
var server_time : int;
var player_id : int;

static func from_player_input(_player_id : int, _server_time : int, _action_buffer : ActionBuffer) -> NetLocalGameHistory:
	var history := NetLocalGameHistory.new();
	history.server_time = _server_time;
	
	# TODO : Transformer les inputs en un paquet UDP-able
	return history;


func to_player_input() -> ActionBuffer:
	
	# TODO : Transformer self en ActionBuffer
	var buffer := ActionBuffer.new();
	return buffer;
