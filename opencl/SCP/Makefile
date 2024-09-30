ROOT_DIR := $(realpath ../../..)
include $(ROOT_DIR)/config.mk

PROJECT := SCP

SRC_DIR := $(VORTEX_HOME)/tests/opencl/$(PROJECT)

SRCS := $(SRC_DIR)/main.cc 

CXXFLAGS += -I$(SRC_DIR)

# Target for copying the kernel file
kernel.cl: $(SRC_DIR)/kernel.cl
	cp $< $@

KERNEL_SRCS := kernel.cl

# Usage: Set the number of iterations
OPTS ?= 

include ../common.mk

