# Include .env file if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Define the target
deploy-transfer:
	@echo "Running deploy script for TransferUSDC to deploy it on Fuji"
	forge script script/TransferUSDC.s.sol --rpc-url $(FUJI_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verifier-url $(SNOWTRACE_VERIFIER_URL) --etherscan-api-key $(SNOWTRACE_API_KEY)

deploy-swap-receiver:
	@echo "Running deploy script for DeployReceiverAndSwap to deploy both contracts on Sepolia"
	forge script script/DeployReceiverAndSwap.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

# Optional: Add a help target to describe how to use the Makefile
help:
	@echo "Usage:"
	@echo "  make deploy-transfer        Run the deploy script with the specified environment variables"
	@echo "  make deploy-swap-receiver        Run the deploy script with the specified environment variables"
