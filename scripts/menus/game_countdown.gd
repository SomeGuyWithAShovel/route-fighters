class_name GameCountdown
extends Node2D

# local only, not any network synchronization

@export var anim_sprite : AnimatedSprite2D = null;
@export var one_sec_timer : Timer = null;

var duration_left : int = 0;

func _ready() -> void :
	assert(anim_sprite != null);
	assert(one_sec_timer != null);
	stop_and_hide();
	return;

func stop_and_hide() -> void :
	one_sec_timer.stop();
	duration_left = 0;
	hide();
	return;

func update_current_frame() -> void :
	anim_sprite.frame = duration_left;
	return;

func start(duration_sec : int = 3) -> void :
	assert(duration_sec < 10);
	
	duration_left = duration_sec;
	update_current_frame();
	show();
	one_sec_timer.start(1);
	return;

func _on_timer_timeout() -> void :
	duration_left -= 1;
	if (duration_left > 0) :
		update_current_frame();
		one_sec_timer.start(1);
		return;
	# else
	stop_and_hide();
	return;
