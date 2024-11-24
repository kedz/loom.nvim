all: lint test-intgration

lint:
	@echo "Running luacheck..."
	@luacheck --config .luacheckrc lua

test-integration:
	@echo "Integration tests..."
	@busted --verbose --output gtest --run integration

.PHONY: all lint test-integration
