extends TextureRect
class_name Planner

@onready var timer : Timer = $Timer
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_play : AnimationPlayer = $AnimationPlayer
@onready var state_machine = anim_tree["parameters/playback"]

## Info display
@onready var calendar : Control = $Control/calendar
@onready var day_label : Label = $Control/calendar/day
@onready var timeslot_segement_label : Label = $Control/calendar/timeslot_segment
@onready var from_time_icon : TextureRect = $Control/calendar/HBoxContainer/from_icon
@onready var to_time_icon : TextureRect = $Control/calendar/HBoxContainer/to_icon
@onready var time_progress_slider : HSlider = $Control/calendar/progress
@export var timeslot_icons : Array[Texture2D] = []
@onready var shop_notice : Control = $Control/shop_notice
@onready var progress_label : Label = $Control/progress/label_2
var active_page_idx : int = 0
var active_page_anim_nodes : PackedStringArray = [
	"calendar_open",
	"progress_open",
]
## FX
@onready var stencil_fx : TextureRect = $Control/stencil_border/stencil_fx
@export var stencil_fx_textures : Array[Texture2D] = []
@onready var stencil_fx_atlas : AtlasTexture = stencil_fx.texture
@onready var stencil_noise : TextureRect = $Control/stencil_noise
@onready var stencil_noise_atlas : AtlasTexture = stencil_noise.texture
var y_pos : float = 0.0
var y_pos_noise : float = 0.0
var flicker_reset : float = 300.0

## Calendar
@onready var schedule : Schedule = Schedule.new()
var time_segments_from_timeslots : Array = [
	[0, 1, 2, 3], ## Night
	[4, 5, 6, 7], ## Morning
	[8, 9, 10, 11], ## Noon
	[12, 13, 14, 15], ## Afternoon
	[0, 1, 2, 3] ## Night Again
]
####
#### Multi Lang
####
var day : PackedStringArray = [
	"SUNDAY",
	"MONDAY",
	"TUESDAY",
	"WEDNESDAY",
	"THURSDAY",
	"FRIDAY",
	"SATURDAY"
]

func set_day(strings : Array) -> void:
	day.clear()
	for s in strings:
		if s is String:
			day.append(s)

var timeslot_segment : PackedStringArray = [
	"midnight",
	"morning",
	"noon",
	"afternoon",
	"midnight"
]

func set_timeslot_segment(strings : Array) -> void:
	timeslot_segment.clear()
	for s in strings:
		if s is String:
			timeslot_segment.append(s)
####
#### End Multi-Lang
####


func update_calendar() -> void:
	var timeslot : int = schedule.get_current_timeslot()
	var day_idx : int = 0
	for idx in schedule.same_day_groups.size():
		if schedule.same_day_groups[idx].has(timeslot):
			day_idx = idx
	day_label.text = day[day_idx]
	var timeslot_data : Schedule.TimeSlot = schedule.time_chart[timeslot]
	timeslot_segement_label.text = timeslot_segment[schedule.timeslot_segment.find(timeslot_data.time_a)]
	from_time_icon.texture = timeslot_icons[schedule.timeslot_segment.find(timeslot_data.time_a)]
	to_time_icon.texture = timeslot_icons[schedule.timeslot_segment.find(timeslot_data.time_b)]
	var time = Time.get_datetime_dict_from_system(false)
	var current_hour : float = time.hour
	current_hour += (float(time.minute) / 60.0)
	var current_hour_progress = inverse_lerp(timeslot_data.time_a, timeslot_data.time_b, current_hour)
	time_progress_slider.value = current_hour_progress


func update_progress(amount_saved : int) -> void:
	if amount_saved >= 1000000:
		if active_page_anim_nodes.has("progress_open"):
			active_page_anim_nodes.remove_at(active_page_anim_nodes.find("progress_open"))
	else:
		var comma_string : String = ""
		var digit_idx : int = 0
		for char in str(amount_saved).reverse():
			if digit_idx == 3 or digit_idx == 6:
				comma_string += ","
			comma_string += char
			digit_idx += 1
		comma_string = "$" + comma_string.reverse()
		progress_label.text = comma_string + "\n/\n$1,000,000"


func _ready() -> void:
	update_calendar()


func _physics_process(delta: float) -> void:
	y_pos += 0.9
	stencil_fx_atlas.region = Rect2(0, y_pos, 4, 4)
	if y_pos > flicker_reset:
		y_pos = 0
		flicker_reset = randf_range(100.0, 500.0)
		stencil_fx_atlas.atlas = stencil_fx_textures.pick_random()
	y_pos_noise += 0.6
	if y_pos_noise > 200.0:
		y_pos_noise = 0.0
	stencil_noise_atlas.region = Rect2(0, y_pos_noise, 128, 70)


func set_shop_notice_page_active(tf : bool) -> void:
	if tf:
		if !active_page_anim_nodes.has("shop_notice_open"):
			active_page_anim_nodes.append("shop_notice_open")
	else:
		if active_page_anim_nodes.has("shop_notice_open"):
			active_page_anim_nodes.remove_at(active_page_anim_nodes.find("shop_notice_open"))
			_rotate_planner_display()


func _rotate_planner_display() -> void:
	active_page_idx += 1
	if active_page_idx >= active_page_anim_nodes.size():
		active_page_idx = 0
	state_machine.travel(active_page_anim_nodes[active_page_idx])


func _on_timer_timeout() -> void:
	timer.stop()
	if active_page_anim_nodes.size() > 1:
		_rotate_planner_display()
	timer.start(5.0)
