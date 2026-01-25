extends Control

@onready var _hp_bar: ProgressBar = %HPBar
@onready var _hp_label: Label = %HPLabel
@onready var _shield_bar: ProgressBar = %ShieldBar
@onready var _weapon_label: Label = %WeaponLabel
@onready var _ammo_label: Label = %AmmoLabel
@onready var _wave_label: Label = %WaveLabel


func _ready() -> void:
	var ev := GGF.events()
	if ev:
		ev.subscribe("player_stats_changed", _on_player_stats_changed)
		ev.subscribe("player_weapon_changed", _on_player_weapon_changed)
		ev.subscribe("player_ammo_changed", _on_player_ammo_changed)
		ev.subscribe("wave_changed", _on_wave_changed)


func _exit_tree() -> void:
	var ev := GGF.events()
	if ev:
		ev.unsubscribe("player_stats_changed", _on_player_stats_changed)
		ev.unsubscribe("player_weapon_changed", _on_player_weapon_changed)
		ev.unsubscribe("player_ammo_changed", _on_player_ammo_changed)
		ev.unsubscribe("wave_changed", _on_wave_changed)


func _on_player_stats_changed(data: Dictionary) -> void:
	var hp := int(data.get("hp", 0))
	var max_hp := int(data.get("max_hp", 0))
	var shield := int(data.get("shield", 0))
	var max_shield := int(data.get("max_shield", 0))

	if _hp_bar:
		_hp_bar.max_value = float(max_hp)
		_hp_bar.value = float(hp)
	if _hp_label:
		_hp_label.text = "%d / %d" % [hp, max_hp]

	if _shield_bar:
		_shield_bar.max_value = float(max_shield)
		_shield_bar.value = float(shield)


func _on_player_weapon_changed(data: Dictionary) -> void:
	var weapon_name := str(data.get("weapon_name", ""))
	if _weapon_label:
		_weapon_label.text = weapon_name


func _on_player_ammo_changed(data: Dictionary) -> void:
	var current := int(data.get("current", -1))
	var max_ammo := int(data.get("max", -1))

	if not _ammo_label:
		return

	if max_ammo < 0 or current < 0:
		_ammo_label.text = "∞"
	else:
		_ammo_label.text = "%d / %d" % [current, max_ammo]


func _on_wave_changed(data: Dictionary) -> void:
	var wave := int(data.get("wave", 0))
	if _wave_label:
		_wave_label.text = "Wave %d" % wave
