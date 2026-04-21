extends Object
# Un pour chaque joueur adverse (en théorie qu'un ?)
class_name ActionBuffer

const DEFAULT_REWIND_FRAMES : int = ceili(3 * GlobalConstant.TARGET_FPS);

var player_move_buffer : Array[Move.Kind];
var player_position_buffer : Array[Vector2]
var newest_frame: int = 0;

func _ready() -> void:
	set_rewind_time(DEFAULT_REWIND_FRAMES);
	
func set_rewind_time(frames : int) -> void:
	player_move_buffer.resize(frames);
	player_position_buffer.resize(frames);

func correct_actions(net_action_buffer : ActionBuffer) -> void:
	# TODO : Comparer les deux bestiaux et corriger self en fonction du distant qui fait autorité
	pass;

func add_move(move : Move.Kind, at : Vector2) -> void:
	var duration_in_frames := Move.duration_in_frames(move);
	
	for i in range(newest_frame, newest_frame + duration_in_frames):
		i %= len(player_move_buffer);
		player_move_buffer[i] = move;
		player_position_buffer[i] = at;
		
	newest_frame = newest_frame + duration_in_frames;
