-- package.lua
return {
	name = "hodgman/gdn",
	version = "0.0.1",
	private = true, -- This prevents us from accidentally publishing this package.
	dependencies = {
		"satom99/litcord",
	}
	files = {
		'*.lua',
		'utils/*.lua',
		'client/*.lua',
		'classes/*.lua',
		'constants/*.lua',
		'structures/*.lua',
	},
}