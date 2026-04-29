class_name GameCountdown
extends Node2D

# local only, not any network synchronization

@export var anim_sprite : AnimatedSprite2D = null;
@export var one_sec_timer : Timer = null;

# $AnimatedSprite2D.sprite_frames is set through this script, no need to set it in the editor
@export var sprite_frame_countdown : SpriteFrames = null;
@export var sprite_frame_fight : SpriteFrames = null;

var duration_left : int = 0; # also used as a "state"

func _ready() -> void :
	assert(anim_sprite != null);
	assert(one_sec_timer != null);
	
	assert(sprite_frame_countdown != null);
	stop_and_hide();
	return;

func stop_and_hide() -> void :
	one_sec_timer.stop();
	duration_left = 0;
	hide();
	return;

func update_current_frame() -> void :
	anim_sprite.sprite_frames = sprite_frame_countdown;
	anim_sprite.frame = duration_left;
	return;

func start(duration_sec : int = 3) -> void :
	assert(duration_sec < 10);
	
	duration_left = duration_sec;
	update_current_frame();
	show();
	one_sec_timer.start(1);
	return;

func countdown_end_success() -> void :
	anim_sprite.sprite_frames = sprite_frame_fight;
	duration_left = -1;
	one_sec_timer.start(1.5);
	return;

func cancel_countdown() -> void :
	stop_and_hide();
	return;

func _on_timer_timeout() -> void :
	if (duration_left > 0) :
		duration_left -= 1;
		if (duration_left > 0) :
			update_current_frame();
			one_sec_timer.start(1);
		else :
			countdown_end_success();
		return;
	
	if (duration_left == -1) :
		stop_and_hide();
		return;
	
	return;
