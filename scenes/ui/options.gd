extends Control
class_name Options

signal close_options

##
##
#signal containered_lang_selection(idx)
##
##
@onready var main : Control = $phone/main
@onready var mus_vol : SliderInput = $phone/main/vcont1/mus_vol
@onready var sfx_vol : SliderInput = $phone/main/vcont1/sfx_vol
@onready var swap_confirm : Button = $phone/main/vcont1/swap_confirm
@onready var language_button : Button = $phone/main/vcont1/set_lang
##
##
@onready var language_selector : LanguageSelector = $phone/language
##
##

var settings_host : Play = null
var showing_lang : bool = false


func _ready():
	open_options()


func set_host(host : Play) -> void:
	settings_host = host


func apply_settings() -> void:
	print("Updating Settings Display")
	mus_vol.value = settings_host.settings.get_mus_vol()
	mus_vol.update_vals(false)
	sfx_vol.value = settings_host.settings.get_sfx_vol()
	sfx_vol.update_vals(false)
	swap_confirm.button_pressed = settings_host.settings.get_a_b_swap()


func open_options():
	language_selector.hide()
	main.show()
	showing_lang = false


func _on_mus_vol_update_value(new_val: Variant) -> void:
	if settings_host != null:
		settings_host.options_update_mus_vol(new_val)


func _on_sfx_vol_update_value(new_val: Variant) -> void:
	if settings_host != null:
		settings_host.options_update_sfx_vol(new_val)


func _on_swap_confirm_toggled(toggled_on: bool) -> void:
	if settings_host != null:
		settings_host.options_update_a_b_swap(toggled_on)


func _on_set_lang_pressed() -> void:
	if !showing_lang:
		main.hide()
		language_selector.show()
		showing_lang = true
		language_selector.focus_top()


func _on_finished_pressed() -> void:
	print("Sending Close Options...")
	emit_signal("close_options")


func _on_language_language_selector_finished() -> void:
	if showing_lang:
		main.show()
		language_selector.hide()
		showing_lang = false
		language_button.grab_focus()
