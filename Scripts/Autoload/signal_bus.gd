##add all signals that need to be called in different script in here
extends Node


#region PaintMode Signals
signal onOpenPaintMode(openPaintMode: bool)
signal onPaintModeChange(willPaint: bool)
signal onMaterialBTNClicked(openMaterialTab: bool)
signal onBrushSizeChanged(value:float)
signal onNewMaterialSelected(coordinate: Vector2i)
#endregion
