extends Node

var entries = {
	"creatures": {
		"display_name": "Creatures",
		"entries": {
			"toadling": {
				"title": "Toadling",
				"art": preload("res://MysticForest/assets/characters/Toadling/Toadling sprite1.png"),
				"text": "A small, knowledgeable frog-like creature. Seems anxious but friendly. He serves as a guide in this strange forest."
			},
			"maestro_croaker": {
				"title": "Maestro Croaker",
				"art": preload("res://MysticForest/assets/characters/Maestro Croaker/Maestro Croaker1.png"),
				"text": "The proud and somewhat arrogant elder of the Frogfolk. A conductor who has lost his orchestra. Deeply cares for his people."
			},
			"grumble": {
				"title": "Grumble",
				"art": preload("res://MysticForest/assets/characters/Grumble frog/Grumble frog1.png"),
				"text": "A grumpy, old frog who plays the drums. He was deeply saddened by the silence of his pumpkin drum."
			},
			"lily": {
				"title": "Lily",
				"art": preload("res://MysticForest/assets/characters/Lily frog/Lily frog1.png"),
				"text": "A young, melancholic flutist. Her music seems connected to the faint lights that dance over the marsh."
			},
			"la_sol": {
				"title": "La & Sol",
				"art": preload("res://MysticForest/assets/characters/Twins Grogs (La&Sol)/La&Sol frog1.png"),
				"text": "Twin frogs who sing in harmony. Their argument silenced the pond, but the restored totem melody brought them back together."
			},
			"myra": {
				"title": "Myra",
				"art": preload("res://MysticForest/assets/characters/Mushrooms/Mycellian Grandma.png"),
				"text": "The matriarch of the Mycelian village. She is deeply worried about her grandchildren and the fading of the Great Willow."
			},
			"elder_spore": {
				"title": "Elder Spore",
				"art": preload("res://MysticForest/assets/characters/Mushrooms/Mycellian Grandpa.png"),
				"text": "The patriarch of the Mycelians. He stands guard in the outer caves, guiding lost travelers and protecting his kin."
			},
			"the_weaver": {
				"title": "The Weaver-Spider",
				"art": preload("res://MysticForest/assets/characters/Spiders/Cross Spider/Cross spider animation17.png"),
				"text": "A colossal, ancient spider trapped by the Heart Crystal. It doesn't seem evil, but rather scared and in pain."
			},
			"spider_warrior": {
				"title": "Spider Warrior",
				"art": preload("res://MysticForest/assets/characters/Spiders/Shadow spider warrior1.png"), # Укажите путь к арту
				"text": "Smaller, aggressive spiders that patrol the labyrinth. They seem driven by fear, attacking anything that emanates light or life. Perhaps they are just protecting their home."
			},
			"spring_hydrangea": {
				"title": "Spring Hydrangea",
				"art": preload("res://MysticForest/assets/objects/Hortensia growing animation/Hortensia growing6.png"), # Укажите путь к арту
				"text": "Beautiful, magically attuned flowers that grow around the Murmuring Glade's spring. Planting their seeds and channeling energy into them helped restore the flow of magic."
			},
			"owl_guardian": {
				"title": "Owl Guardian",
				"art": preload("res://MysticForest/assets/characters/Owl/Owl.png"), # Укажите путь к вашему арту совы
				"text": "An ancient, stone-like guardian of the Hollow Tree Library. It seems to be trapped in a magical slumber, dreaming of a world that has lost its sounds."
			}
		}
	},
	"echos_diary": {
		"display_name": "Echo's Diary",
		"entries": {
			"the_fading": {
				"title": "The Fading",
				#"art": preload(),
				"text": "Toadling told me the forest is fading. It feels... tired. The colors are muted, the sounds are quiet. He said it's because the Mirror Path to the human world broke."
			},
			"path_of_fear": {
				"title": "The Path of Fear",
				"text": "Echo spoke of two great spirits guarding the final fragments: the Owl Guardian in the Hollow Tree Library, and the Weaver-Spider in the deep caves. I must find them and earn their trust."
}
			# ...
		}
	}
}

# Здесь будет храниться, какие записи игрок уже открыл
var unlocked_entries = {
	"creatures": [],
	"echos_diary": []
}

# Функция для "открытия" новой записи
func unlock_entry(category_key, entry_key):
	if entries.has(category_key) and entries[category_key].entries.has(entry_key):
		if not entry_key in unlocked_entries[category_key]:
			unlocked_entries[category_key].append(entry_key)
			print("New journal entry unlocked: ", category_key, " -> ", entry_key)
