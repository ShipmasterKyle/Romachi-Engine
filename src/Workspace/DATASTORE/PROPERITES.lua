local module = {
	SAVE = true,
	STUDIO_SAVE = false, --Prevents devs from saving data
	AUTO_SAVE = true,
	SAFE_SAVE = true,
	
	LOAD = true,
	STUDIO_LOAD = true,

	ATTEMPTS = 10, -- Save / Load
	INTERVAL = 60, -- For Auto Save
	DATASTORE = "Romachi Pre-Alpha", -- Datastore
}

return module