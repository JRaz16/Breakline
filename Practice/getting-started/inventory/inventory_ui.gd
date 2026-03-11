class_name InventoryUI extends Control

@export var inventory: Inventory

@onready var grid: GridContainer = $Grid

func open() -> void:
	get_tree().paused = true
	self.visible = true

func close() -> void:
	self.visible = false
	get_tree().paused = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_inventory"):
		get_viewport().set_input_as_handled()
		self.close()

# Called when the node enters the scene tree for the first time.
func refresh_ui() -> void:
	for cell in grid.get_children():
		cell.queue_free()
	
	for slot in inventory.slots:
		var slot_panel:Panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(80, 80)
		var vbox:VBoxContainer = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		if slot:
			var tex:TextureRect = TextureRect.new()
			tex.texture = slot.item.icon
			tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tex.custom_minimum_size = Vector2(64, 64)
			vbox.add_child(tex)
			
			var label:Label = Label.new()
			label.text = str(slot.quantity)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(label)
		else:
			var empty:Label = Label.new()
			empty.text = ""
			vbox.add_child(empty)
		
		slot_panel.add_child(vbox)
		grid.add_child(slot_panel)

func _init() -> void:
	# Hide by default
	self.visible = false

func _ready() -> void:
	if inventory:
		refresh_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_inventory_inventory_updated() -> void:
	pass # Replace with function body.
