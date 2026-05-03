extends Node

var walk_sound: AudioStreamWAV = preload("res://sounds/walk.tres")
var attack_sound: AudioStreamWAV = preload("res://sounds/attack.tres")
var enemy_hurt_sound: AudioStreamWAV = preload("res://sounds/enemy_hurt.tres")
var player_hurt_sound: AudioStreamWAV = preload("res://sounds/player_hurt.tres")
var door_sound: AudioStreamWAV = preload("res://sounds/door.tres")
var button_sound: AudioStreamWAV = preload("res://sounds/button.tres")
var key_sound: AudioStreamWAV = preload("res://sounds/key.tres")
var death_sound: AudioStreamWAV = preload("res://sounds/death.tres")

var num_players = 8
var available_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Create a pool of audio players
	for i in range(num_players):
		var p = AudioStreamPlayer.new()
		add_child(p)
		available_players.append(p)

func play_sound(stream: AudioStreamWAV) -> void:
	for p in available_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	
	# If all busy, use the first one anyway
	if available_players.size() > 0:
		available_players[0].stream = stream
		available_players[0].play()

func play_walk() -> void:
	play_sound(walk_sound)

func play_attack() -> void:
	play_sound(attack_sound)

func play_enemy_hurt() -> void:
	play_sound(enemy_hurt_sound)

func play_player_hurt() -> void:
	play_sound(player_hurt_sound)

func play_door() -> void:
	play_sound(door_sound)

func play_button() -> void:
	play_sound(button_sound)

func play_key() -> void:
	play_sound(key_sound)

func play_death() -> void:
	play_sound(death_sound)
