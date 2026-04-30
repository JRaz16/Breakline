extends Node
## Attach this script to a node of the scene (e.g., the root node) to run
## several simple GOAP test cases.


func _ready():
	#if process_mode != PROCESS_MODE_DISABLED:
		test_case_00()
		test_case_01()
		test_case_02()
		test_case_03()

func test_case_00():
	var initial_state1:WorldState = WorldState.new({
		"has_phone": Property.Value.new(self, true),
		"has_recipe": Property.Value.new(self, false),
		"is_hungry": Property.Value.new(self, true)
	})

	var initial_state2:WorldState = WorldState.new({
		"has_phone": Property.Value.new(self, false),
		"has_recipe": Property.Value.new(self, true),
		"is_hungry": Property.Value.new(self, true)
	})

	var initial_state3:WorldState = WorldState.new({
		"has_phone": Property.Value.new(self, false),
		"has_recipe": Property.Value.new(self, false),
		"is_hungry": Property.Value.new(self, true)
	})

	var goal_state:WorldState = WorldState.new({
		"is_hungry": Property.Value.new(self, false)
	})

	var actions:Array[Action] = [
		Action.new(
			"order pizza", 2,
			WorldState.new({
				"has_phone": Property.Value.new(self, true)
			}),
			WorldState.new({
				"is_hungry": Property.Value.new(self, false)
			})
		),
		Action.new(
			"bake pie", 8,
			WorldState.new({
				"has_recipe": Property.Value.new(self, true)
			}),
			WorldState.new({
				"is_hungry": Property.Value.new(self, false)
			})
		)
	]

	var plan = Goap.search(actions, initial_state1, goal_state)
	var plan_str:String = "Plan A for " + str(goal_state.properties.keys()) + " is... "
	for action in plan:
		plan_str += action.name + " > "
	print(plan_str.substr(0, plan_str.length() - 3))

	plan = Goap.search(actions, initial_state2, goal_state)
	plan_str = "Plan B for " + str(goal_state.properties.keys()) + " is... "
	for action in plan:
		plan_str += action.name + " > "
	print(plan_str.substr(0, plan_str.length() - 3))

	plan = Goap.search(actions, initial_state3, goal_state)
	plan_str = "Plan C for " + str(goal_state.properties.keys()) + " is... "
	for action in plan:
		plan_str += action.name + " > "
	print(plan_str.substr(0, plan_str.length() - 3))


func test_case_01():
	var initial_state:WorldState = WorldState.new({
		"weapon_is_armed": Property.Value.new(self, false),
		"weapon_is_loaded": Property.Value.new(self, false),
		"target_is_dead": Property.Value.new(self, false)
	})

	var goal_state:WorldState = WorldState.new({
		"target_is_dead": Property.Value.new(self, true)
	})

	var actions:Array[Action] = [
		Action.new(
			"draw weapon", 1,
			WorldState.new({}),
			WorldState.new({
				"weapon_is_armed": Property.Value.new(self, true)
			})
		),
		Action.new(
			"load weapon", 2,
			WorldState.new({
				"weapon_is_armed": Property.Value.new(self, true)
			}),
			WorldState.new({
				"weapon_is_loaded": Property.Value.new(self, true)
			})
		),
		Action.new(
			"attack", 3,
			WorldState.new({
				"weapon_is_loaded": Property.Value.new(self, true)
			}),
			WorldState.new({
				"target_is_dead": Property.Value.new(self, true)
			})
		)
	]

	var plan = Goap.search(actions, initial_state, goal_state)
	var plan_str:String = "Plan for " + str(goal_state.properties.keys()) + " is... "
	for action in plan:
		plan_str += action.name + " > "
	print(plan_str.substr(0, plan_str.length() - 3))


func test_case_02():
	var initial_state:WorldState = WorldState.new({
		"has_money": Property.Value.new(self, false),
		"has_tool": Property.Value.new(self, false),
		"has_raw_material": Property.Value.new(self, false),
		"has_refined_material": Property.Value.new(self, false),
		"at_job": Property.Value.new(self, false),
		"at_mine": Property.Value.new(self, false),
		"at_shop": Property.Value.new(self, false),
		"at_refinery": Property.Value.new(self, false),
		"at_workbench": Property.Value.new(self, false)
	})

	var goal_state:WorldState = WorldState.new({
		"has_tool": Property.Value.new(self, true)
	})

	var actions:Array[Action] = [
		Action.new(
			"goto mine", 1,
			WorldState.new({}),
			WorldState.new({
				"at_shop": Property.Value.new(self, false),
				"at_workbench": Property.Value.new(self, false),
				"at_refinery": Property.Value.new(self, false),
				"at_mine": Property.Value.new(self, true)
			})
		),
		Action.new(
			"goto refinery", 1,
			WorldState.new({}),
			WorldState.new({
				"at_job": Property.Value.new(self, false),
				"at_mine": Property.Value.new(self, false),
				"at_shop": Property.Value.new(self, false),
				"at_workbench": Property.Value.new(self, false),
				"at_refinery": Property.Value.new(self, true)
			})
		),
		Action.new(
			"goto job", 1,
			WorldState.new({}),
			WorldState.new({
				"at_mine": Property.Value.new(self, false),
				"at_workbench": Property.Value.new(self, false),
				"at_refinery": Property.Value.new(self, false),
				"at_shop": Property.Value.new(self, false),
				"at_job": Property.Value.new(self, true)
			})
		),
		Action.new(
			"goto shop", 1,
			WorldState.new({}),
			WorldState.new({
				"at_job": Property.Value.new(self, false),
				"at_mine": Property.Value.new(self, false),
				"at_workbench": Property.Value.new(self, false),
				"at_refinery": Property.Value.new(self, false),
				"at_shop": Property.Value.new(self, true)
			})
		),
		Action.new(
			"goto workbench", 1,
			WorldState.new({}),
			WorldState.new({
				"at_job": Property.Value.new(self, false),
				"at_mine": Property.Value.new(self, false),
				"at_shop": Property.Value.new(self, false),
				"at_refinery": Property.Value.new(self, false),
				"at_workbench": Property.Value.new(self, true)
			})
		),
		Action.new(
			"shop", 1,
			WorldState.new({
				"has_money": Property.Value.new(self, true),
				"at_shop": Property.Value.new(self, true)
			}),
			WorldState.new({
				"has_money": Property.Value.new(self, false),
				"has_tool": Property.Value.new(self, true)
			})
		),
		Action.new(
			"work", 3,
			WorldState.new({
				"at_job": Property.Value.new(self, true)
			}),
			WorldState.new({
				"has_money": Property.Value.new(self, true)
			})
		),
		Action.new(
			"refine", 1,
			WorldState.new({
				"has_raw_material": Property.Value.new(self, true),
				"at_refinery": Property.Value.new(self, true)
			}),
			WorldState.new({
				"has_raw_material": Property.Value.new(self, false),
				"has_refined_material": Property.Value.new(self, true)
			})
		),
		Action.new(
			"craft", 1,
			WorldState.new({
				"has_refined_material": Property.Value.new(self, true),
				"at_workbench": Property.Value.new(self, true)
			}),
			WorldState.new({
				"has_refined_material": Property.Value.new(self, false),
				"has_tool": Property.Value.new(self, true)
			})
		),
		Action.new(
			"gather", 1,
			WorldState.new({
				"at_mine": Property.Value.new(self, true)
			}),
			WorldState.new({
				"has_raw_material": Property.Value.new(self, true)
			})
		)
	]

	var plan = Goap.search(actions, initial_state, goal_state)
	var plan_str:String = "Plan for " + str(goal_state.properties.keys()) + " is... "
	for action in plan:
		plan_str += action.name + " > "
	print(plan_str.substr(0, plan_str.length() - 3))


func test_case_03():
	var initial_state:WorldState = WorldState.new({
		"is_cold": Property.Value.new(self, true),
		"is_hungry": Property.Value.new(self, true),
		"is_lonely": Property.Value.new(self, true),
		"is_sleepy": Property.Value.new(self, true),
		"near_fire": Property.Value.new(self, false),
		"near_bush": Property.Value.new(self, false),
		"near_bed": Property.Value.new(self, false),
		"near_friend": Property.Value.new(self, false),
		"in_bed": Property.Value.new(self, false),
		"has_berries": Property.Value.new(self, false)
	})

	var goal_states:Array[WorldState] = [
		WorldState.new({
			"is_cold": Property.Value.new(self, false)
		}),
		WorldState.new({
			"is_hungry": Property.Value.new(self, false)
		}),
		WorldState.new({
			"is_sleepy": Property.Value.new(self, false)
		}),
		WorldState.new({
			"is_lonely": Property.Value.new(self, false)
		})
	]

	var actions:Array[Action] = [
		Action.new(
			"goto bed", 1,
			WorldState.new({}),
			WorldState.new({
				"near_bed": Property.Value.new(self, true),
				"near_bush": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, false),
				"near_friend": Property.Value.new(self, false)
			})
		),
		Action.new(
			"goto bush", 1,
			WorldState.new({}),
			WorldState.new({
				"near_bed": Property.Value.new(self, false),
				"near_bush": Property.Value.new(self, true),
				"near_friend": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, false)
			})
		),
		Action.new(
			"goto fire", 1,
			WorldState.new({}),
			WorldState.new({
				"near_bed": Property.Value.new(self, false),
				"near_bush": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, true),
				"near_friend": Property.Value.new(self, false),
				"is_cold": Property.Value.new(self, false)
			})
		),
		Action.new(
			"goto friend", 1,
			WorldState.new({}),
			WorldState.new({
				"near_bed": Property.Value.new(self, false),
				"near_bush": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, false),
				"near_friend": Property.Value.new(self, true)
			})
		),
		Action.new(
			"lie down", 1,
			WorldState.new({
				"near_bed": Property.Value.new(self, true),
			}),
			WorldState.new({
				"in_bed": Property.Value.new(self, true)
			})
		),
		Action.new(
			"gather berries", 1,
			WorldState.new({
				"near_bush": Property.Value.new(self, true),
			}),
			WorldState.new({
				"has_berries": Property.Value.new(self, true)
			})
		),
		Action.new(
			"eat berries", 1,
			WorldState.new({
				"has_berries": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_hungry": Property.Value.new(self, false)
			})
		),
		Action.new(
			"sleep", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_sleepy": Property.Value.new(self, false)
			})
		),
		Action.new(
			"cuddle", 1,
			WorldState.new({
				"near_friend": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_lonely": Property.Value.new(self, false)
			})
		)
	]

	var current_state:WorldState = initial_state
	for goal in goal_states:
		if current_state.satisfies(goal): continue
		var plan:Array[Action] = Goap.search(actions, current_state, goal)
		var plan_str:String = "Plan for " + str(goal.properties.keys()) + " is... "
		for action in plan:
			plan_str += action.name + " > "
		print(plan_str.substr(0, plan_str.length() - 3))
		if not Goap.execute(plan, current_state):
			print("!!! Plan execution failed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
