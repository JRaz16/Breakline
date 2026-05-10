extends Node

# EVENT / SIGNAL BUS PATTERN
# This script acts as a centralized communication hub.
# Different game systems communicate through signals instead
# of directly referencing each other, reducing coupling
# between gameplay objects and managers.


signal player_died
signal level_completed(next_level_path: String)
signal dash_used
signal game_paused
signal game_resumed
