extends Control
class_name CustomerDex

@onready var name_label : Label = $Panel/content/picture_bg/picture_overlay/customer_name
@onready var pic_rect : TextureRect = $Panel/content/picture_bg/customer_pic
@onready var stats_label : Label = $Panel/content/vbox/stats/value_label
@onready var description : Label = $Panel/content/vbox/description
@onready var page_label : Label = $Panel/content/pgnum

@export var customer_names_internal : PackedStringArray = [
	"Tommy", "Teddy", "Ted", "Al", "Emo", "Karen", "Patient", "Mustard",
	"Dancer", "Punk", "Toad", "Persistant", "Anxiety", "Haircut",
	"Jimmie", "Mr. Pink", "Macho Liam"
]
@export var customer_names_display : PackedStringArray = [
	"Tommy", "Teddy", "Ted", "Al", "Emo", "Karen", "Patient", "Mustard",
	"Dancer", "Punk", "Toad", "Persistant", "Anxiety", "Haircut",
	"Jimmie", "Mr. Pink", "Macho Liam"
]
@export var customer_images : Array[Texture2D]
@export var customer_descriptions : PackedStringArray = [
	"Species: Lima Bean\nHeight: 4'10\nFavorite Ingredient: Lettuce\n\
	Can often be seen around the local theater... like all the time. Probably \
	lives there. Is insistant that actors must perform their own stunts.",
	"Species: Plorb\nHeight: 6'7\nFavorite Ingredient: Cheese\n\
	Extemely lonely and worried about what others think. This dude won't come \
	to the counter unless we've made eye-contact at least 5 times.",
	"Species: Bronk\nHeight 5'4\nFavorite Ingredient: Meat\n\
	Always a good time with Ted. This dude's so freakin funny. Clever too. \
	I wish I could orchestrate jokes the way he does.\n\nShame about the \
	depression.",
	"Species: Plorb\nHeight: 6'0\nFavorite Ingredient: Meat\n\
	Local handy-man. Probably has fixed everything in here at one point... \
	except for his meal.",
	"Species: Unknown\nHeight: 5'10\nFavorite Ingredient: N/A\n\
	Dramatic, Sporadic, Confusing... I have no idea where to begin with this \
	one. I don't even know how to start a conversation through their endless \
	monologue.",
	"Species: Bronk\nHeight: 5'2\nFavorite Ingredient: Time\n\
	Over time, we have come to a mutual agreement... you see, I too really \
	want to get this over with. The sooner I'm done, the sooner you're gone.",
	"Species: Djinn\nHeight: 5'11\nFavorite Ingredient: CHEESE\n\
	Honestly a really nice guy and strangely comforting to talk to. \
	I can actively sense that they're listening, and they never interrupt \
	unless I'm struggling to find my words. Also the dude looks like cheese.",
	"Species: Lima Bean\nHeight: 5'1\nFavorite Ingred- Mustard it's Mustard\n\
	Always comes in after closing the theater, then continues to slam down \
	hand-fulls of mustard. I mean I make it fresh and have to throw it away \
	anyway... still it's unnerving.",
	"Species: Djinn\nHeight: 6'8\nFavorite Ingredient: Bread\n\
	One of my favorites. She's in and out, has simple requests, and manages \
	to make an enchanting breeze as she dances out the door.",
	"Species: Lima Bean\nHeight: 4'10 or 5'6 with hair\nFavorite Ingredient: \
	Ketchup\nI try to be an honest chef. I make food how the people want it, \
	it makes me happy. This dude though, this dude is a freak.",
	"Species: Australien\nHeight: 5'10\nFavorite Ingredient: N/A\n\
	I think they're trying to make their own sandwhich somewhere, I don't get \
	it. Just let me make your sandwhich for you. It's my whole job. I'm not \
	a grocery store!",
	"Species: Lima Bean\nHeight: 5'3\nFavorite Ingredient: Burgers\n\
	Just order a triple. I can do that. Nothing bad will happen. You will get \
	the same amount of food, and be on your way to continue deliveries.\n\n\
	oh wait... you're just wasting your time here aren't you...",
	"Species: Fish\nHeight: 0'2 without the apparatus\nFavorite Ingredient: \
	Bread Crumbs\nWhen people don't have time to feed fishes at the pond... the \
	fish, find a way.",
	"Species: Bronk\nHeight: 5'11\nFavorite Ingredient: Paint\n\
	He's about to go on a date... I know it. He gets a haircut, then comes \
	here to eat just before meeting up with is date. I'm guessing he is worried \
	about how he eats or gets too nervous and ends up starving.",
	"Species: GetBentOS\nHeight: Standard\nFavorite Ingredient: Lettuce\n\
	Sarcastic and Rude... as intended. Sometimes I convince myself the \
	\"Thank you have a nice day\" isn't disingenuous.",
	"Species: Plorb\nHeight: 6'7\nFavorite Ingredient: Tomato\n\
	Extremely physically slow. Works at the therapy center, so I'm guessing \
	he has trained himself to be this slow and balanced.",
	"Species: Djinn\nHeight: 5'4\nFavorite Ingredient: Meat\n\
	Will not stop pestering me about protein intake. I'm sure it's important \
	but there are other vitamins out there too.\n\nUsually hangs out at the gym \
	with that other guy..."
]

var current_page : int = 0

####
#### Multi Lang Setters
####

func set_display_names(strings : Array):
	customer_names_display.clear()
	for s in strings:
		if s is String:
			customer_names_display.append(s)

func set_customer_descriptions(strings : Array):
	customer_descriptions.clear()
	for s in strings:
		if s is String:
			customer_descriptions.append(s)

####
#### End Multi Lang Setters
####

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
	name_label.text = customer_names_display[target]
	pic_rect.texture = customer_images[target]
	print("TODO")
	#var stats : Play.Stats.CustomerStats = 
	#stats_label.text = 
	description.text = customer_descriptions[target]
	description.visible_ratio = 0.0
	page_label.text = str(target + 1) + "\n--\n" + str(customer_names_internal.size())


func _physics_process(delta: float) -> void:
	if description.visible_ratio < 1.0:
		description.visible_ratio += 0.018
