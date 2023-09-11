ARTIFACTS_DIR := $(ARTIFACTS_DIR)

install-shim: ; @command -v sam-bats-shim || (echo "sam-bats-shim command not found, installing from toolbox" && toolbox install sam-bats-shim)

build-LambdaSkill:
	cd $$ARTIFACTS_DIR && sam-bats-shim -t CocktailAlchemist-1.0 -p CocktailAlchemist-1.0 -o $$ARTIFACTS_DIR

build-FunctionCocktailAlchemistLambdagamma9BE6C33A: install-shim build-LambdaSkill