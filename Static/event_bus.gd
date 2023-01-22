extends Node

# Platformer
signal platformer_resource_updated(resource)

signal pickable_map_selection_changed(start_pos, end_pos)
signal target_set(position)

# Game Actions
signal pickup_entered_pipe(type)
signal pause()
signal resume()
