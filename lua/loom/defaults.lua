local Defaults = {}

-- Ollama default configuration.
Defaults.HOST = "localhost"
Defaults.PORT = "11434"
Defaults.MODEL = "tinyllama"
Defaults.config = function(self)
	return {
		["host"] = self.HOST,
		["port"] = self.PORT,
		["model"] = self.MODEL,
	}
end

return Defaults
