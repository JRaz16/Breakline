# Three clearly defined game systems
# 1) Dash System
# 2) Wall Running/Climbing System
# 3) Slide System
# 4) Goal Ring System

# Three design patterns

# SINGLETON PATTERN:
# settings.gd, game_manager.gd, and event_bus.gd are implemented as
# autoload singletons to provide globally accessible
# persistent game data and configuration.

# EVENT / SIGNAL BUS PATTERN:
# A centralized EventBus singleton is used to broadcast
# gameplay events between systems. The Player emits events
# such as death, level completion, and pausing, while
# game_manager listens and reacts accordingly. This keeps
# gameplay systems loosely coupled and easier to maintain.

# COMMAND PATTERN:
# Player actions are encapsulated into command objects
# (dash_command & jump_command) which separate
# input handling from gameplay behavior.
