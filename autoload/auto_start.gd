extends Node

func _ready() -> void:
	print("[AutoStart] Waiting to start game...")
	await get_tree().create_timer(1.0).timeout
	# Find Main node
	var main = get_tree().root.get_node_or_null("Main")
	if main != null:
		print("[AutoStart] Found Main, triggering start")
		main._on_start_requested()
	else:
		print("[AutoStart] Main not found at /root/Main")
		# Try to find it
		for child in get_tree().root.get_children():
			print("[AutoStart] Root child: ", child.name)
			if child.name == "Main":
				print("[AutoStart] Found Main via iteration")
				child._on_start_requested()
				break

	# Wait for game to load then test interactions
	await get_tree().create_timer(2.0).timeout
	test_interactions()


func test_interactions() -> void:
	print("[AutoStart] Testing interactions...")
	# Find player
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("[AutoStart] Player not found!")
		return
	print("[AutoStart] Found player at: ", player.global_position)

	# Move player to Bed (should already be nearby)
	print("[AutoStart] Moving to Bed...")
	player.global_position = Vector2(-60, 5)
	await get_tree().create_timer(0.5).timeout

	# Try interact
	if player.nearby_interactable != null:
		print("[AutoStart] Interactable found: ", player.nearby_interactable.name)
		player.nearby_interactable.interact()
	else:
		print("[AutoStart] No interactable nearby at Bed position")

	await get_tree().create_timer(1.0).timeout

	# Move player to Door
	print("[AutoStart] Moving to Door...")
	player.global_position = Vector2(120, -40)
	await get_tree().create_timer(0.5).timeout

	if player.nearby_interactable != null:
		print("[AutoStart] Interactable found: ", player.nearby_interactable.name)
		player.nearby_interactable.interact()
	else:
		print("[AutoStart] No interactable nearby at Door position")

	await get_tree().create_timer(1.0).timeout

	# Move player to Portal
	print("[AutoStart] Moving to Portal...")
	player.global_position = Vector2(150, 0)
	await get_tree().create_timer(1.0).timeout

	print("[AutoStart] Test complete")
