extends Node


#region PaintModeUI

@export var PaintModeUI: Control
var PaintModeOpen: bool

#this will open and close the PaintModeUI
func onPaintModeBTN_Click() -> void:
	PaintModeOpen = !PaintModeOpen
	SignalBus.emit_signal("onOpenPaintMode", PaintModeOpen)
	PaintModeUI.visible = PaintModeOpen
		
#endregion
