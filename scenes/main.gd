extends Node2D

@export var pipe_scene : PackedScene


var game_running : bool
var game_over : bool
var scroll
var score
const SCROlL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPES_DELAY : int = 100
const PIPES_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	# Reset variable
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$GameOver.hide()
	$StartLayer.show()
	get_tree().call_group("pipes","queue_free")
	$ScoreLabel.text = str(score)
	$ScoreLabel.hide()
	pipes.clear()
	generate_pipes()
	$Bird.reset()

func _input(event: InputEvent) -> void:
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()
				$StartLayer.hide()
				$ScoreLabel.show()
func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	# Start pipe times
	$PipeTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		scroll += SCROlL_SPEED
		# Reset Scroll
		if scroll >= screen_size.x:
			scroll = 0
		# Move ground node
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROlL_SPEED


func _on_pipe_timer_timeout() -> void:
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPES_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPES_RANGE, PIPES_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)
	
func scored():
	score += 1
	$ScoreLabel.text = str(score)
	
func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()
		
func stop_game():
	$PipeTimer.stop()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true
		
func bird_hit():
	$Bird.falling = true
	stop_game()

func _on_ground_hit() -> void:
	$Bird.falling = false
	stop_game()

func _on_game_over_restart() -> void:
	new_game()
