# Un pour chaque joueur adverse (en théorie qu'un ?)
class_name ActionBuffer
extends RefCounted

const DEFAULT_REWIND_FRAMES : int = ceili(3 * GlobalConstant.TARGET_FPS);

# Array remplie de 0 dans le ready
var player_move_buffer : Array[MoveInformation] = [];
var newest_frame: int = 0;
var player_id : int = -1;

func _init(_player_id : int, _rewind_time : int = DEFAULT_REWIND_FRAMES) -> void:
	player_id = _player_id;
	set_rewind_time(_rewind_time);
	player_move_buffer.fill(MoveInformation.new(Vector2(0.0, 0.0), -1, Move.Kind.NOTHING));
	
static func from_move_buffer(_player_id : int, _player_move_buffer : Array[MoveInformation], _newest_frame : int) -> ActionBuffer:
	var action_buffer := ActionBuffer.new(_player_id);
	action_buffer.player_move_buffer = _player_move_buffer;
	action_buffer.newest_frame = _newest_frame;
	return action_buffer;
	
func set_rewind_time(frames : int) -> void:
	player_move_buffer.resize(frames);

class CommonIndices:
	# [Cur-first - Cur-last[ représente l'ensemble des éléments affecté par le net_buffer
	var cur_first : int;
	var cur_last  : int;
	# net-first est le premier élément de net tel que cur-first.time >= net-first.time
	var net_first : int;
	
	func _init(_cur_first : int = 0, _cur_last : int = 0, _net_first : int = 0) -> void:
		cur_first = _cur_first;
		cur_last  = _cur_last;
		net_first = _net_first;
	
func find_common_sub_buffer(_net_action_buffer : ActionBuffer) -> CommonIndices:
	var res := CommonIndices.new();
	var cur_i := newest_frame-1;
	var last_net_i := _net_action_buffer.newest_frame - 1;
	
	var n_ab := _net_action_buffer;
	
	while n_ab.player_move_buffer[last_net_i].server_time_started < player_move_buffer[cur_i].server_time_started:
		cur_i -= 1;
		if cur_i < 0: cur_i = len(player_move_buffer);
	
	# +1 car on veut le dernier exclus (pour une boucle for)
	res.cur_last = cur_i+1;
	
	# Vu que c'est circulaire
	cur_i = newest_frame;
	# On skip toutes les valeurs invalides mises là pour remplir le buffer
	while player_move_buffer[cur_i].server_time_started < 0: 
		cur_i = (cur_i + 1) % len(n_ab.player_move_buffer);
	
	var first_net_i := _net_action_buffer.newest_frame;
	if n_ab.player_move_buffer[first_net_i].server_time_started < player_move_buffer[cur_i].server_time_started:
		var net_i := first_net_i;
		while n_ab.player_move_buffer[net_i].server_time_started < player_move_buffer[cur_i].server_time_started:
			net_i = (net_i + 1) % len(n_ab.player_move_buffer);
		res.net_first = net_i;
		res.cur_first = cur_i;
	else:
		# premier net plus recent que current last
		while n_ab.player_move_buffer[first_net_i].server_time_started > player_move_buffer[cur_i].server_time_started:
			cur_i = (cur_i + 1) % len(player_move_buffer);
		res.cur_first = cur_i;
	return res;
	
func correct_actions(net_action_buffer : ActionBuffer, current_server_time : int, ggpo : GGPO) -> MoveInformation:
	var net_last := net_action_buffer.get_last_move();
	var cur_last := self.get_last_move();
	assert(net_last.server_time_started <= cur_last.server_time_started, 
		"La simulation est plus vieille que l'action reçue ?");
	
	var common_indices : CommonIndices = find_common_sub_buffer(net_action_buffer);
	var nb_moves_added := common_indices.cur_last - common_indices.cur_first;
	if nb_moves_added < 0:
		nb_moves_added += len(player_move_buffer);
		
	newest_frame = common_indices.cur_first;
	for i in range(nb_moves_added):
		var net_i := (i + common_indices.net_first) % len(net_action_buffer.player_move_buffer);
		var net_move := net_action_buffer.player_move_buffer[net_i];
		add_move(net_move.kind, net_move.position, net_move.server_time_started);
	
	return resimulate(current_server_time, ggpo);
	
func resimulate(server_time : int, ggpo : GGPO) -> MoveInformation:
	var last_move := get_last_move();
	var simulation_time := last_move.server_time_started;
	while simulation_time + Move.duration_in_frames(last_move.kind) < server_time:
		var move_position := last_move.position + GlobalConstant.TARGET_DELTA_TIME*Move.position_delta(last_move.kind);
		simulation_time += Move.duration_in_frames(last_move.kind);
		var move_kind := ggpo.predict_move(self);
		
		add_move(move_kind, move_position, simulation_time);
		last_move = get_last_move();
		
	return get_last_move();
	
func get_last_move() -> MoveInformation:
	return player_move_buffer[newest_frame-1];

func add_move(move : Move.Kind, at : Vector2, time : int) -> void:
	var move_info := MoveInformation.new(at, time, move);
	player_move_buffer[newest_frame] = move_info;
	newest_frame = (newest_frame + 1) % len(player_move_buffer);
