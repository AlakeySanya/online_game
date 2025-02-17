extends Control



func _ready() -> void:
	Signals.connect("stamina", self, "stamina_change")

func _process(delta: float) -> void:
	pass

func stamina_change(stamina):
	$Label.text = str(stamina)
