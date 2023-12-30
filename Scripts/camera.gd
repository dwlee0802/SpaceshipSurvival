extends Camera2D

class_name Camera

var noise = FastNoiseLite.new()

static var noise_i: float = 0.0

static var SHAKE_DECAY_RATE: float = 2.0

var NOISE_SHAKE_SPEED: float = 30.0

var NOISE_SHAKE_STRENGTH: float = 60.0

static var shake_strength: float = 0

var tileSize = 30

var screenDragging: bool = false
var screenDragStart
var screenDragOffset

static var cam


# Called when the node enters the scene tree for the first time.
func _ready():
	noise.frequency = 2
	noise.fractal_octaves = 3
	cam = self
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	if shake_strength < 2:
		shake_strength = 0
		
	offset = get_noise_offset(delta)
	
	position = Game.survivor.position


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = zoom * 1.2
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = zoom * 0.8

		
static func ShakeScreen(intensity, duration):
	noise_i = 0
	shake_strength = intensity
	SHAKE_DECAY_RATE = duration


func get_noise_offset(delta: float):
	noise_i += delta * NOISE_SHAKE_SPEED
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)


static func CenterCameraAt(position: Vector2):
	cam.position = position
