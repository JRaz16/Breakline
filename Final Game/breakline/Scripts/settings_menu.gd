extends VBoxContainer

@onready var sensitivity_slider = $Sens

func _ready():
	sensitivity_slider.value = Settings.mouse_sensitivity

func _on_sens_value_changed(value: float) -> void:
	Settings.mouse_sensitivity = value
