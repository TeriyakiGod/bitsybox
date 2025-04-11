ifeq ($(APP_PARAM), )
    APP_PARAM:=../Makefile.param
    include $(APP_PARAM)
endif

export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)

PKG_TARGET := bitsybox-build

PKG_NAME := bitsybox
PKG_BIN ?= out
GAMES_DIR := $(PKG_BIN)/games
DEMO_GAMES_SRC := res/demo_games

SDL2_LIB_PATH := $(RK_PROJECT_OUTPUT)/rootfs_uclibc_rv1106/usr/lib
SDL2_INCLUDE := ./include/sdl2

LDFLAGS := \
    -L$(SDL2_LIB_PATH) \
    -Wl,--gc-sections \
    -Wl,--as-needed \
    -pthread \
    -lSDL2 \
    -lstdc++ \
    -lm \
    -static-libgcc

CFLAGS := -I$(SDL2_INCLUDE) -O2

BUILD_RELEASE_GAMES_SUBDIR=games

# path to C source files
SRC_FILES=src/bitsybox/*.c src/bitsybox/duktape/*.c


all: $(PKG_TARGET)
	@echo "build $(PKG_NAME) done"

bitsybox-build:
	@echo "Building $(PKG_NAME)..."
	@rm -rf $(PKG_BIN)
	@mkdir -p $(PKG_BIN)/bin
	@mkdir -p $(GAMES_DIR)
	
	# Build the binary
	$(RK_APP_CROSS)-gcc $(CFLAGS) $(SRC_FILES) -o $(PKG_BIN)/bin/bitsybox $(LDFLAGS)
	
	# Copy demo games
	@if [ -d "$(DEMO_GAMES_SRC)" ]; then \
		echo "Copying demo games from $(DEMO_GAMES_SRC) to $(GAMES_DIR)"; \
		cp -r $(DEMO_GAMES_SRC)/* $(GAMES_DIR); \
	else \
		echo "Warning: Demo games directory $(DEMO_GAMES_SRC) not found"; \
	fi
	
	$(call MAROC_COPY_PKG_TO_APP_OUTPUT, $(RK_APP_OUTPUT), $(PKG_BIN))
	@echo "Build complete - games included in $(GAMES_DIR)"

clean:
	@rm -rf $(PKG_BIN)

distclean: clean

info:
	@echo -e "$(C_YELLOW)-------------------------------------------------------------------------$(C_NORMAL)"
	@echo -e "RK_APP_TYPE=$(RK_APP_TYPE)"
	@echo -e "option support as follow:"
	@echo -e "	BITSYBOX"
	@echo -e "$(C_YELLOW)-------------------------------------------------------------------------$(C_NORMAL)"