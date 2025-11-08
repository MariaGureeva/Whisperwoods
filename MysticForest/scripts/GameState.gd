extends Node

signal inventory_changed
signal resonance_changed(new_value)
 
var entrance_name: String = "SpawnPoint_CabinExit"
var inventory := {}

var max_resonance: float = 100.0
var current_resonance: float = 0.0:
	set(value):
		current_resonance = clamp(value, 0.0, max_resonance)
		emit_signal("resonance_changed", current_resonance)

var talked_to_toadling_once: bool = false
var cabinet_cutscene_played: bool = false
var seeds_found: bool = false
var second_dialogue_played: bool = false
var spring_healed: bool = false
var post_spring_dialogue_played: bool = false
var sleep_cutscene_played: bool = false
var toadling_met_morning: bool = false
var attunement_unlocked: bool = false

var act2_quest_started: bool = false
var mist_marsh_quest_started: bool = false
var mist_marsh_quest_completed: bool = false
var rhythm_note_found: bool = false
var melody_note_found: bool = false
var melody_reconstructed: bool = false
var harmony_note_found: bool = false
var met_grumble: bool = false
var met_lily: bool = false
var met_twins: bool = false
var fungal_reach_quest_started: bool = false
var fungal_reach_path_unlocked: bool = false
var fungal_reach_main_quest_started: bool = false
var fungal_reach_quest_completed: bool = false
var fungal_reach_final_cutscene_played: bool = false
var mirror_partially_fixed: bool = false
var moon_lake_path_unlocked: bool = false
var act_2_completed: bool = false

var act_3_intro_played: bool = false
var owl_quest_started: bool = false
var owl_puzzle_solved: bool = false
var owl_quest_completed: bool = false
var spider_quest_started: bool = false
var spider_quest_completed: bool = false
var spider_is_following: bool = false
var mycelian_reconciliation_played: bool = false
var spider_is_leading_to_den: bool = false
var spider_leading_path_index: int = 0
var spider_passage_cutscene_played: bool = false



func reset_for_new_game():
	print("--- GAMESTATE RESET FOR NEW GAME ---")
	entrance_name = "SpawnPoint_CabinExit"
	inventory = {}
	
	self.current_resonance = 0.0
	
	talked_to_toadling_once = false
	cabinet_cutscene_played = false
	seeds_found = false
	second_dialogue_played = false
	spring_healed = false
	post_spring_dialogue_played = false
	sleep_cutscene_played = false
	toadling_met_morning = false
	attunement_unlocked = false
	
	act2_quest_started = false
	mist_marsh_quest_started = false
	mist_marsh_quest_completed = false
	rhythm_note_found = false
	melody_note_found = false
	melody_reconstructed = false
	harmony_note_found = false
	met_grumble = false
	met_lily = false
	met_twins = false
	fungal_reach_quest_started = false
	fungal_reach_path_unlocked = false
	fungal_reach_main_quest_started = false
	fungal_reach_quest_completed = false
	fungal_reach_final_cutscene_played = false
	mirror_partially_fixed = false
	moon_lake_path_unlocked = false
	act_2_completed = false
	
	act_3_intro_played = false
	owl_quest_started = false
	owl_puzzle_solved = false
	owl_quest_completed = false
	spider_quest_started = false
	spider_quest_completed = false
	spider_is_following = false
	mycelian_reconciliation_played = false
	spider_passage_cutscene_played = false

	
	emit_signal("inventory_changed")

func has_item(item_name: String) -> bool:
	return inventory.has(item_name) and inventory[item_name] > 0

func remove_item(item_name: String):
	if has_item(item_name):
		inventory[item_name] -= 1
		if inventory[item_name] <= 0:
			inventory.erase(item_name)
		emit_signal("inventory_changed")

func add_item(item_name: String, amount: int = 1):
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount
	emit_signal("inventory_changed")
