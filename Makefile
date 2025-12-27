
# Makefile for The Trapper

.PHONY: all build test clean deploy

all: build

build:
	git submodule update --init --recursive
	forge build

test:
	forge test

clean:
	forge clean

# Example deployment command (adjust as needed)
deploy-local:
	forge script script/DeployTraps.s.sol --rpc-url localhost --broadcast
