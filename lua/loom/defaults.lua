M = {}

-- Ollama default configuration.
M.HOST = "localhost"
M.PORT = "11434"
M.MODEL = "tinyllama"
M.config = function(self)
	return {
		["host"] = self.HOST,
		["port"] = self.PORT,
		["model"] = self.MODEL,
	}
end

return M
