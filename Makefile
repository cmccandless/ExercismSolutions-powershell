EXTENSION :=ps1

SOURCE_FILES := $(shell find */* -type f -name '*$(EXTENSION)')
EXERCISES := $(shell find */* -type f -name '*$(EXTENSION)' | cut -d/ -f1 | uniq)
LINT_TARGETS := $(addprefix lint-,$(EXERCISES))
OUT_DIR=.build
OBJECTS=$(addprefix $(OUT_DIR)/,$(EXERCISES))
MIGRATE_OBJECTS := $(addsuffix /.exercism/metadata.json, $(EXERCISES))

.PHONY: all init no-skip clean test check-migrate
all: test
pre-push pre-commit: lint test

init:
	pwsh -Command 'Install-Module -Force -SkipPublisherCheck -Scope CurrentUser -Name Pester'

clean:
	rm -rf $(OUT_DIR)

test: $(EXERCISES)

check-migrate: $(MIGRATE_OBJECTS)

$(MIGRATE_OBJECTS):
	@ [ -f $@ ] || $(error "$(shell echo $@ | cut -d/ -f1) has not been migrated")

$(EXERCISES): %: $(OUT_DIR)/%

$(OUT_DIR):
	@ mkdir -p $@

.SECONDEXPANSION:

GET_DEP = $(filter $(patsubst $(OUT_DIR)/%,%,$@)%,$(SOURCE_FILES))
$(OBJECTS): $$(GET_DEP) | $(OUT_DIR)
	$(eval EXERCISE := $(patsubst $(OUT_DIR)/%,%,$@))
	@ echo "Testing $(EXERCISE)..."
	@ bin/run-test.sh $(EXERCISE)
	@ touch $@
