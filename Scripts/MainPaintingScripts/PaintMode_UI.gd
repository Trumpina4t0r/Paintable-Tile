extends Control

@onready var brushSizeLabel: Label = get_node("Panel/VBoxContainer/VBoxContainer/BrushSizeLabel")
@onready var paintModeLabel: Label = get_node("PaintMode_Label")
@onready var MaterialSelector: Control = get_node("MaterialSelectorUI")
##add all the paintable resources script in this array it will automatically get added 
#or if you want to assign them manually (needs to be buttons) you could then add all the childs of the grid box on _ready()
#but you will have to attach a script that contains PaintableResources_Main on each buttons
@export var resources: Array[PaintableResources_Main]

func _ready() -> void:
	UiManager.PaintModeUI = self
	#set some default values
	brushSizeLabel.text = str("Brush Size: ", 1, "x", 1)
	var slider: HSlider = get_node("Panel/VBoxContainer/VBoxContainer/HSlider")
	slider.value = 1
	#add all the material from the array into the grid
	AddMaterialInGrid()
	
	#if you added all the material individually you would need to un comment this and remove AddMaterialInGrid()
	#AddChildInGrid()

#region Binding Buttons
func onPaintBTNClicked() -> void:
	SignalBus.emit_signal("onPaintModeChange",true)
	paintModeLabel.text = str("Painting")


func onEraseBTNClicked() -> void:
	SignalBus.emit_signal("onPaintModeChange",false)
	paintModeLabel.text = str("Erasing")

func onBrushSizeChanged(value: float) -> void:
	brushSizeLabel.text = str("Brush Size: ", value, "x", value)
	SignalBus.emit_signal("onBrushSizeChanged",value)


func onMaterialBTN_Clciked() -> void:
	MaterialSelector.visible = !MaterialSelector.visible


func onCloseBTN_Clicked() -> void:
	MaterialSelector.visible = !MaterialSelector.visible
#endregion

func AddMaterialInGrid() -> void:
	var gridMaterialContainer: GridContainer = get_node("MaterialSelectorUI/Panel/VScrollBar/GridContainer")
	#add every resource script in the array of the script attach to the container
	for resource in resources:
		var btn = Button.new()
		btn.icon = resource.image
		btn.flat = true  #you could remove those line if your texture are the correct size
		btn.expand_icon = true #<- this one too
		btn.custom_minimum_size = Vector2(32,32)#<- this one too
		btn.pressed.connect(func():
			SignalBus.emit_signal("onNewMaterialSelected",resource.AtlasCoordinate)
		)
		gridMaterialContainer.add_child(btn)

func AddChildInGrid():
	#if you add buttons manually it will look something like this
	var gridMaterialContainer: GridContainer = get_node("MaterialSelectorUI/Panel/VScrollBar/GridContainer")
	for child in gridMaterialContainer.get_children():
		resources.append(child.PaintableResources_Main) #<-- child."the variable name that you would have created"
		#you would also need to bind each button on press with the signal "onNewMaterialSelected go see AddMaterialInGrid()
