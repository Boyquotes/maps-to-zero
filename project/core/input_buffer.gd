class_name InputBuffer
extends Node

var input_buffer = [] # A list to store the inputs
var double_tap_timers = {} # A dictionary to store the timers for each input
var double_tap_time = 0.5 # The time between taps for a double tap

func add_input(input_event:InputEvent, duration := 0.2):
	# Create a timer node for the input
	var timer = Timer.new()
	timer.wait_time = duration
	add_child(timer)
	
	input_buffer.append(input_event) # Add the input to the buffer
	timer.timeout.connect(_remove_input.bind(input_event, timer)) # Connect the timeout signal to remove the input
	timer.start()
	
	# Create a timer node for the input if it's not already in the double_tap_timers dictionary
	if not double_tap_timers.has(input_event):
		var double_tap_timer = Timer.new()
		double_tap_timer.wait_time = double_tap_time
		add_child(double_tap_timer)
		
		# Connect the timeout signal to remove the input from the double_tap_timers dictionary
		double_tap_timer.timeout.connect(_remove_double_tap_timer.bind(input_event, double_tap_timer))
		
		# Add the timer to the double_tap_timers dictionary
		double_tap_timers[input_event] = double_tap_timer
		
		# If the timer is running, stop it
		double_tap_timers[input_event].stop()
		
		# Start the timer
		double_tap_timers[input_event].start()

func _remove_input(input_event:InputEvent, timer:Timer):
	# Remove the input from the buffer
	input_buffer.remove_at(input_buffer.find(input_event))
	
	# Queue the timer node for freeing
	timer.queue_free()

func has_action(action: String) -> bool:
	# Check if the input is in the buffer
	for input_event in input_buffer:
		if input_event.is_action_pressed(action):
			return true
	return false

func is_input_in_buffer(input_event:InputEvent):
	# Check if the input is in the buffer
	return input_event in input_buffer

func flush_buffer_up_to_input(input_event:InputEvent):
	if not is_input_in_buffer(input_event):
		# Return if the input is not in the buffer
		return
	for i in range(len(input_buffer)):
		if input_buffer[i] == input_event:
			# Remove the target input and all inputs before it
			input_buffer = input_buffer.slice(i + 1)
			break

func _remove_double_tap_timer(input_event:InputEvent, timer: Timer):
	# Remove the input from the double_tap_timers dictionary
	double_tap_timers.erase(input_event)
	timer.queue_free()

func is_double_tap(input_event:InputEvent):
	# Check if the input is in the double_tap_timers dictionary
	return double_tap_timers.has(input_event)

func flush_buffer_up_to_double_tap():
	for i in range(len(input_buffer)):
		if is_double_tap(input_buffer[i]):
			# Remove all inputs up to the double tap
			input_buffer = input_buffer.slice(i)
			break
