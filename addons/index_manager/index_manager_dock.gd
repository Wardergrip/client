@tool
extends Control

@onready var reload_button: Button = $VBoxContainer/ReloadBtn
@onready var asset_tab_container := $VBoxContainer/AssetTabContainer

var asset_types: Array[String] = [
	"textures",
	"fonts",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_button.pressed.connect(_build_asset_list)
	_build_asset_list()


func _build_asset_list():
	print('reloading asset list')
	
	for child in asset_tab_container.get_children():
		asset_tab_container.remove_child(child)
	
	AssetIndexer.re_index_files()	
	var dynamic_assets := AssetIndexer.get_asset_map() as Dictionary
	
	# create the containers for all the categories
	var category_continers = {}
	
	var asset_tab_all := VBoxContainer.new()
	asset_tab_all.name = "all"
	category_continers["all"] = asset_tab_all
	
	for asset_type in asset_types:
		var asset_tab_typed := VBoxContainer.new()
		asset_tab_typed.name = asset_type
		category_continers[asset_type] = asset_tab_typed
	
	# create the all category
	var asset_keys = dynamic_assets.keys()
	for key in asset_keys:
		var asset_label_all = Label.new()
		asset_label_all.text = "dyn://" + key
		asset_label_all.mouse_filter = Control.MOUSE_FILTER_PASS
		asset_label_all.tooltip_text = dynamic_assets[key]
		asset_label_all.gui_input.connect(
			func asset_callback(input_event):
				_copy_asset_id(input_event, asset_label_all.text)
		)
		category_continers["all"].add_child(asset_label_all)
		
		var asset_id = Identifier.from_string(key)
		var asset_type = asset_id.get_content_type()
		var asset_label_category = Label.new()
		asset_label_category.text = asset_id.get_content_prefix() + asset_id.get_content_identifier().to_string()
		asset_label_category.mouse_filter = Control.MOUSE_FILTER_STOP
		asset_label_category.tooltip_text = dynamic_assets[key]
		
		asset_label_category.gui_input.connect(
			func asset_callback(input_event):
				_copy_asset_id(input_event, asset_label_category.text)
		)
		category_continers[asset_type].add_child(asset_label_category)
		
	# add all tabs to the tab container
	for category_name in category_continers.keys():
		asset_tab_container.add_child(category_continers[category_name])


func _copy_asset_id(input_event: InputEvent, clipboard_text: String):
	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_LEFT and input_event.pressed:
			print("callback for label " + clipboard_text + " entered")
			DisplayServer.clipboard_set(clipboard_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass