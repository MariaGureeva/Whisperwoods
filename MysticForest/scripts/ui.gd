extends CanvasLayer

@onready var menu = $Menu
@onready var inventory_tab = $Menu/MenuWindow/TabsContainer/InventoryTab
@onready var journal_tab = $Menu/MenuWindow/TabsContainer/JournalTab
@onready var map_tab = $Menu/MenuWindow/TabsContainer/MapTab

@onready var inventory_page = $Menu/MenuWindow/Pages/InventoryPage
@onready var journal_page = $Menu/MenuWindow/Pages/JournalPage
@onready var map_page = $Menu/MenuWindow/Pages/MapPage

@onready var resonance_bar = $HUD/ResonanceBar
@onready var item_slot_template = $Menu/MenuWindow/Pages/InventoryPage/ItemSlot

@onready var categories_container = $Menu/MenuWindow/Pages/JournalPage/CategoriesList/CategoriesContainer
@onready var journal_art_display = $Menu/MenuWindow/Pages/JournalPage/DisplayPanel/ArtDisplay
@onready var journal_text_display = $Menu/MenuWindow/Pages/JournalPage/DisplayPanel/TextDisplay
@export var pixel_font: FontFile

var item_icons = {
	"whisper_seed": preload("res://MysticForest/assets/objects/Seed.png"),
	"rhythm_stone": preload("res://MysticForest/assets/objects/Inventory/Act2 inventory1.png"),
	"melody_feather": preload("res://MysticForest/assets/objects/Inventory/Act2 inventory2.png"),
	"harmony_shells": preload("res://MysticForest/assets/objects/Inventory/Act2 inventory3.png"),
	"mirror_shard": preload("res://MysticForest/assets/objects/Inventory/Mirror shard.png")
}

var item_names = {
	"whisper_seed": "Whisper Seed",
	"rhythm_stone": "Rhythm Stone",
	"melody_feather": "Melody Feather",
	"harmony_shells": "Harmony Shells",
	"mirror_shard": "Mirror Shard"
}

var tabs
var pages

func _ready():
	menu.hide()
	tabs = [inventory_tab, journal_tab, map_tab]
	pages = [inventory_page, journal_page, map_page]
	
	inventory_tab.pressed.connect(func(): _on_tab_selected("inventory"))
	journal_tab.pressed.connect(func(): _on_tab_selected("journal"))
	map_tab.pressed.connect(func(): _on_tab_selected("map"))
	
	resonance_bar.max_value = GameState.max_resonance
	resonance_bar.value = GameState.current_resonance
	GameState.resonance_changed.connect(update_resonance_bar)
	
	GameState.inventory_changed.connect(update_inventory)
	update_inventory()
	
	_on_tab_selected("inventory")
	
	if is_instance_valid(journal_text_display):
		journal_text_display.add_theme_font_override("font", pixel_font)
		journal_text_display.add_theme_font_size_override("font_size", 16)
		journal_text_display.add_theme_color_override("font_color", Color("2f4d44"))

func _process(delta):
	if Input.is_action_just_pressed("ui_inventory"):
		menu.visible = not menu.visible
		get_tree().paused = menu.visible

func update_resonance_bar(new_value: float):
	resonance_bar.value = new_value

func update_inventory():
	var all_children = inventory_page.get_children()
	var slots = []
	for child in all_children:
		if child.name != "ItemSlot_Template":
			slots.append(child)
	
	var item_keys = GameState.inventory.keys()
	for i in range(slots.size()):
		var slot = slots[i]
		if i < item_keys.size():
			var item_name = item_keys[i]
			var quantity = GameState.inventory[item_name]
			if item_icons.has(item_name) and item_icons[item_name] != null:
				var display_name = item_names.get(item_name, item_name.capitalize())
				var item_data = {
					"name": display_name,
					"texture": item_icons[item_name],
					"quantity": quantity
				}
				slot.set_item(item_data)
		else:
			slot.clear_slot()

func build_journal_ui():
	for child in categories_container.get_children():
		child.queue_free()
	
	clear_full_entry_display()
	
	for category_key in JournalData.entries:
		var category_data = JournalData.entries[category_key]
		var category_label = Label.new()
		category_label.text = category_data.display_name
		category_label.add_theme_font_override("font", pixel_font)
		category_label.add_theme_font_size_override("font_size", 24)
		category_label.add_theme_color_override("font_color", Color.DARK_SLATE_GRAY)
		categories_container.add_child(category_label)
		
		if JournalData.unlocked_entries.has(category_key):
			for entry_key in JournalData.unlocked_entries[category_key]:
				var entry_data = JournalData.entries[category_key].entries[entry_key]
				var entry_button = Button.new()
				entry_button.text = "  - " + entry_data.title
				entry_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				entry_button.add_theme_font_override("font", pixel_font)
				entry_button.add_theme_font_size_override("font_size", 20)
				var stylebox_empty = StyleBoxEmpty.new()
				entry_button.add_theme_stylebox_override("normal", stylebox_empty)
				entry_button.add_theme_stylebox_override("hover", stylebox_empty)
				entry_button.add_theme_stylebox_override("pressed", stylebox_empty)
				entry_button.pressed.connect(func(): show_full_entry(entry_data))
				categories_container.add_child(entry_button)

func show_full_entry(entry_data: Dictionary):
	# Проверяем, существует ли узел для арта
	if is_instance_valid(journal_art_display):
		# --- НОВОЕ УСЛОВИЕ ---
		# Проверяем, есть ли в данных ключ 'art'
		if entry_data.has("art"):
			journal_art_display.texture = entry_data.art
			journal_art_display.show()
		else:
			# Если арта нет, просто прячем картинку
			journal_art_display.texture = null
			journal_art_display.hide()
	
	# С текстом все остается по-старому
	if is_instance_valid(journal_text_display):
		journal_text_display.text = entry_data.text

func clear_full_entry_display():
	if is_instance_valid(journal_art_display):
		journal_art_display.texture = null
	if is_instance_valid(journal_text_display):
		journal_text_display.text = ""

func _on_tab_selected(page_name: String):
	inventory_page.hide()
	journal_page.hide()
	map_page.hide()
	
	if page_name == "inventory":
		inventory_page.show()
	elif page_name == "journal":
		journal_page.show()
		build_journal_ui()
	elif page_name == "map":
		map_page.show()
