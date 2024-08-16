VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage

VERILATOR_FLAGS += --cc --exe --build
VERILATOR_FLAGS += -Wall
# VERILATOR_FLAGS += --trace

VERILATOR_INPUT = csrc/NVBoardTest.cpp vsrc/top.v

# NVBoard部分
TOPNAME = top
NXDC_FILES = constr/top.nxdc

SRC_AUTO_BIND = $(abspath ./auto_bind.cpp)

$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

VERILATOR_INPUT += ./auto_bind.cpp

include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

all:

sim: $(SRC_AUTO_BIND) $(NVBOARD_ARCHIVE)
	@echo
	@echo "---------- verilator run ----------"
	@echo

	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS))


	@echo
	@echo "---------- RUN ----------"
	obj_dir/Vtop

	@echo
	@echo "---------- DONE ----------"

#	$(call git_commit, "sim RTL")

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core


# include ../Makefile
