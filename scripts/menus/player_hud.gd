@tool
class_name PlayerHUD
extends Control

var hbox : HBoxContainer = null;
var label : TextureRect = null;
var bar : TextureProgressBar = null;
var player_textures : Array[Texture2D];

func set_vars() -> void :
	hbox = $VBoxContainer/HBoxContainer;
	assert(hbox != null);
	label = $VBoxContainer/HBoxContainer/Label;
	assert(label != null);
	bar = $VBoxContainer/ProgressBar;
	assert(bar != null);
	player_textures = [
		load("res://assets/text/player_01.png"),
		load("res://assets/text/player_02.png")
	];
	assert(player_textures.size() == 2);
	return;

@export_category("Set left or right")

# in the end, having this as a tool isn't that useful, since even on "editable children" instantiated scenes,
# we can't modify the order of child nodes. (we can in the editor, but it isn't saved correctly).

@export_tool_button("set_left")
var var_editor_set_left = editor_set_left;
func editor_set_left() -> void :
	print("editor_set_left");
	set_layout_as_player_left();
	return;

@export_tool_button("set_right")
var var_editor_set_right = editor_set_right;
func editor_set_right() -> void :
	print("editor_set_right");
	set_layout_as_player_right();
	return;

func set_layout_as_player_left() -> void :
	set_vars();
	bar.fill_mode = TextureProgressBar.FillMode.FILL_LEFT_TO_RIGHT;
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN;
	var pad : ColorRect = hbox.get_child(1) as ColorRect;
	if (pad != null) :
		hbox.move_child(pad, 0); 
		pass;
	# label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
	# swapping Label and Padding.
	label.texture = player_textures[0];
	
	if (Engine.is_editor_hint()) :
		EditorInterface.mark_scene_as_unsaved();
		pass;
	return;

func set_layout_as_player_right() -> void :
	set_vars();
	bar.fill_mode = TextureProgressBar.FillMode.FILL_RIGHT_TO_LEFT;
	hbox.alignment = BoxContainer.ALIGNMENT_END;
	# swapping Label and Padding.
	var pad : ColorRect = hbox.get_child(0) as ColorRect;
	if (pad != null) :
		hbox.move_child(pad, 1); 
		pass;
	# label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
	label.texture = player_textures[1];
	
	if (Engine.is_editor_hint()) :
		EditorInterface.mark_scene_as_unsaved();
		pass;
	return;

func _ready() -> void :
	set_vars();
	return;

func player_joined() -> void :
	# print("PLAYER_HUD : ", get_transform());
	set_progress_100(100.0);
	show();
	return;

func player_quit() -> void :
	hide();
	return;

func set_progress_100(new_value : float) :
	assert((new_value >= 0.0) && (new_value <= 100.0));
	bar.value = new_value;
	return;
