extends Object
# Un pour chaque joueur adverse (en théorie qu'un ?)
class_name ActionBuffer

const DEFAULT_REWIND_FRAMES : int = ceili(3 * GlobalConstant.TARGET_FPS);

var player_move_buffer : Array[Move.Kind];
var oldestIndex : int = 0;
var newestIndex : int = 0;
var simulated : Array[bool];

func _ready() -> void:
	set_rewind_time(DEFAULT_REWIND_FRAMES);
	
func set_rewind_time(frames : int) -> void:
	player_move_buffer.resize(frames);
	simulated.resize(frames);

func add_move(move : Move.Kind) -> void:
	
	var duration_in_frames := Move.duration_in_frames(move);
	
	for i in range(newestIndex, newestIndex + duration_in_frames):
		i %= len(player_move_buffer);
		player_move_buffer[i] = move;

func correct_move(move : Move.Kind, at_frame : int) -> void:
	
