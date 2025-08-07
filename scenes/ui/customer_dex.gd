extends Control
class_name CustomerDex

@onready var name_label : Label = $Panel/content/picture_bg/picture_overlay/customer_name
@onready var pic_rect : TextureRect = $Panel/content/picture_bg/customer_pic
@onready var stats_label : Label = $Panel/content/vbox/stats/value_label
@onready var description_a : Label = $Panel/content/vbox/description_a
@onready var description_b : Label = $Panel/content/vbox/description_b
@onready var page_label : Label = $Panel/content/pgnum

@export var customer_names_internal : PackedStringArray = [
	"Tommy", "Teddy", "Ted", "Al", "Emo", "Karen", "Patient", "Mustard",
	"Dancer", "Punk", "Toad", "Persistant", "Anxiety", "Haircut",
	"Jimmie", "Mr. Pink", "Macho Liam", "R.A.T."
]
@export var customer_names_display : PackedStringArray = [
	"Tommy", "Teddy", "Ted", "Al", "Emo", "Karen", "Patient", "Mustard",
	"Dancer", "Punk", "Toad", "Persistant", "Anxiety", "Haircut",
	"Jimmie", "Mr. Pink", "Macho Liam", "R.A.T."
]
@export var customer_images : Array[Texture2D]
@export var customer_descriptions_a : PackedStringArray = [
	"Species: Lima Bean\nHeight: 4'10\nFavorite Ingredient: Lettuce",
	"Species: Plorb\nHeight: 6'7\nFavorite Ingredient: Cheese",
	"Species: Bronk\nHeight 5'4\nFavorite Ingredient: Meat",
	"Species: Plorb\nHeight: 6'0\nFavorite Ingredient: Meat",
	"Species: Unknown\nHeight: 5'10\nFavorite Ingredient: N/A",
	"Species: Bronk\nHeight: 5'2\nFavorite Ingredient: Time",
	"Species: Djinn\nHeight: 5'11\nFavorite Ingredient: CHEESE",
	"Species: Lima Bean\nHeight: 5'1\nFavorite Ingred- Mustard it's Mustard",
	"Species: Djinn\nHeight: 6'8\nFavorite Ingredient: Bread",
	"Species: Lima Bean\nHeight: 4'10 or 5'6 with hair\nFavorite Ingredient: \
	Ketchup",
	"Species: Australien\nHeight: 5'10\nFavorite Ingredient: N/A",
	"Species: Lima Bean\nHeight: 5'3\nFavorite Ingredient: Burgers",
	"Species: Fish\nHeight: 0'2 without the apparatus\nFavorite Ingredient: \
	Bread Crumbs",
	"Species: Bronk\nHeight: 5'11\nFavorite Ingredient: Paint",
	"Species: GetBentOS\nHeight: Standard\nFavorite Ingredient: Lettuce",
	"Species: Plorb\nHeight: 6'7\nFavorite Ingredient: Tomato",
	"Species: Djinn\nHeight: 5'4\nFavorite Ingredient: Meat",
	"Species: Rat\nHeight: 5'3\nFavorite Ingredient: Cheese",
]
@export var customer_descriptions_b : PackedStringArray = [
	"Can often be seen around the local theater... like all the time. Probably \
	lives there. Is insistant that actors must perform their own stunts.",
	"Extemely lonely and worried about what others think. This dude won't come \
	to the counter unless we've made eye-contact at least 5 times.",
	"Always a good time with Ted. This dude's so freakin funny. Clever too. \
	I wish I could orchestrate jokes the way he does.\n\nShame about the \
	depression.",
	"Local handy-man. Probably has fixed everything in here at one point... \
	except for his meal.",
	"Dramatic, Sporadic, Confusing... I have no idea where to begin with this \
	one. I don't even know how to start a conversation through their endless \
	monologue.",
	"Over time, we have come to a mutual agreement... you see, I too really \
	want to get this over with. The sooner I'm done, the sooner you're gone.",
	"Honestly a really nice guy and strangely comforting to talk to. \
	I can actively sense that they're listening, and they never interrupt \
	unless I'm struggling to find my words. Also the dude looks like cheese.",
	"Always comes in after closing the theater, then continues to slam down \
	hand-fulls of mustard. I mean I make it fresh and have to throw it away \
	anyway... still it's unnerving.",
	"One of my favorites. She's in and out, has simple requests, and manages \
	to make an enchanting breeze as she dances out the door.",
	"Ketchup\nI try to be an honest chef. I make food how the people want it, \
	it makes me happy. This dude though, this dude is a freak.",
	"I think they're trying to make their own sandwhich somewhere, I don't get \
	it. Just let me make your sandwhich for you. It's my whole job. I'm not \
	a grocery store!",
	"Just order a triple. I can do that. Nothing bad will happen. You will get \
	the same amount of food, and be on your way to continue deliveries.\n\n\
	oh wait... you're just wasting your time here aren't you...",
	"Bread Crumbs\nWhen people don't have time to feed fishes at the pond... the \
	fish, find a way.",
	"He's about to go on a date... I know it. He gets a haircut, then comes \
	here to eat just before meeting up with is date. I'm guessing he is worried \
	about how he eats or gets too nervous and ends up starving.",
	"Sarcastic and Rude... as intended. Sometimes I convince myself the \
	\"Thank you have a nice day\" isn't disingenuous.",
	"Extremely physically slow. Works at the therapy center, so I'm guessing \
	he has trained himself to be this slow and balanced.",
	"Will not stop pestering me about protein intake. I'm sure it's important \
	but there are other vitamins out there too.\n\nUsually hangs out at the gym \
	with that other guy...",
	"Reginald Atly Tigillicuny\n\nConstantly trying to outshine the fame of \
	his father, he found comfort being the strongest at the gym.",
]
var customer_name_unknown : String = "UNKNOWN"
@export var customer_image_unknown : Texture2D
var customer_desc_a_unknown : String = "Data Unavailable\n - Serve more orders..."
var customer_desc_b_unknown : String = "Description Unavailable\n - Serve 10 or more Fantastic Orders"


var current_page : int = 0
var customer_stats : Array[Play.Stats.CustomerStat] = []

####
#### Multi Lang Setters
####

func set_label_defaults(strings : Array):
	customer_name_unknown = strings[0]
	customer_desc_a_unknown = strings[1]
	customer_desc_b_unknown = strings[2]


func set_display_names(strings : Array):
	customer_names_display.clear()
	for s in strings:
		if s is String:
			customer_names_display.append(s)

func set_customer_descriptions_a(strings : Array):
	customer_descriptions_a.clear()
	for s in strings:
		if s is String:
			customer_descriptions_a.append(s)

func set_customer_descriptions_b(strings : Array):
	customer_descriptions_b.clear()
	for s in strings:
		if s is String:
			customer_descriptions_b.append(s)

####
#### End Multi Lang Setters
####

func assign_stats(stats : Play.Stats):
	customer_stats.clear()
	for _name in customer_names_internal:
		customer_stats.append(stats.fetch_customerstat(_name))


func open_dex():
	current_page = 0
	_load_page(0)


func _on_pagebutton_pressed(dir: int) -> void:
	print("CustomerDex PageButton: ", dir)
	var new_val = current_page + dir
	if new_val > customer_names_internal.size() - 1:
		new_val = 0
	elif new_val < 0:
		new_val = customer_names_internal.size() - 1
	_load_page(new_val)


func _load_page(target : int):
	current_page = target
	name_label.text = customer_name_unknown
	pic_rect.texture = customer_image_unknown
	stats_label.text = "0\n0\n0"
	description_a.text = customer_desc_a_unknown
	description_b.text = customer_desc_b_unknown
	var stats : Play.Stats.CustomerStat = customer_stats[target]
	stats_label.text = \
		str(stats.get_fantastic_orders()) + "\n" + \
		str(stats.get_satisfactory_orders()) + "\n" + \
		str(stats.get_disappointing_orders())
	if stats.get_orders_served() >= 1:
		pic_rect.texture = customer_images[target]
	if stats.get_orders_served() >= 5 \
	or stats.get_fantastic_orders() >= 2 \
	or stats.get_disappointing_orders() >= 1:
		name_label.text = customer_names_display[target]
	if stats.get_fantastic_orders() >= 4 \
	or stats.get_satisfactory_orders() >= 8 \
	or stats.get_orders_served() >= 15:
		description_a.text = customer_descriptions_a[target]
	if stats.get_fantastic_orders() >= 10:
		description_b.text = customer_descriptions_b[target]
	description_b.visible_ratio = 0.0
	page_label.text = str(target + 1) + "\n--\n" + str(customer_names_internal.size())


func _physics_process(delta: float) -> void:
	if description_b.visible_ratio < 1.0:
		description_b.visible_ratio += 0.018
