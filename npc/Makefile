BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir

$(shell mkdir -p $(OBJ_DIR))

TOP_NAME ?= ysyx
NPCARGS ?= 
IMG ?= 

VERILATOR = verilator

# 常规参数 将verilog代码翻译为C++代码后直接生成可执行文件
VERILATOR_FLAGS = -Mdir $(OBJ_DIR) -cc --exe --build --x-assign fast -Wall --top-module $(TOP_NAME) -y $(abspath, ./vsrc)
INC_FLAGS = $(addprefix -I, $(abspath ./csrc/Include))
# 需要llvm
LLVMFLAGS = $(shell llvm-config --cxxflags) -fPIE
LLVMFLAGS = $(echo $LLVMFLAGS | sed 's/ -D__STDC_FORMAT_MACROS//')  # 去掉D__STDC_FORMAT_MACROS
LLVMLIBS = $(shell llvm-config --libs)
LLVMLIBS += -lreadline

# 是否开启trace
TRACE_IS_ON ?= ON
ifeq ($(TRACE_IS_ON),ON)
	VERILATOR_FLAGS += --trace
endif

vsrc ?= $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
csrc ?= $(shell find $(abspath ./csrc/src) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

# 输入参数
VERILATOR_INPUTS = $(abspath $(vsrc)) $(abspath $(csrc))


default: run
all: run

run:
	@echo
	# @echo "---------------- Verilator running -----------------"
	@$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUTS) -CFLAGS -O2 \
		$(addprefix -CFLAGS , $(INC_FLAGS)) $(addprefix -CFLAGS , $(LLVMFLAGS)) $(addprefix -LDFLAGS , $(LLVMLIBS))\
		--Wno-UNUSEDSIGNAL
	@# 运行可执行程序
	@echo
	@echo "------------------- Simulation ---------------------"
	@echo
	@echo
	$(OBJ_DIR)/V$(TOP_NAME) $(NPCARGS) $(IMG)
	@echo
	@echo "-------------------- Finish -----------------------"

# --------------------------- NVboard ----------------------------"
#

NXDC_FILES = constr/$(TOP_NAME).nxdc
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
# 生成引脚绑定函数
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

NVBOARD_INPUTS += $(SRC_AUTO_BIND)

# nvboard的构建规则
include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS)

NVBOARD_INPUTS += $(NVBOARD_ARCHIVE)

sim: $(SRC_AUTO_BIND)
	@echo
	@echo "----------------------- Verilator running --------------------"
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUTS) $(NVBOARD_INPUTS) $(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS))
	@echo
	@echo "----------------------- NVboard running ----------------------"
	@echo
	@echo
	$(OBJ_DIR)/V$(TOP_NAME)
	@echo
	@echo "--------------------------- Finish ---------------------------"

clean:
	rm -rf $(BUILD_DIR)


#	$(call git_commit, "sim RTL")

# maintainer-copy::
# clean mostlyclean distclean maintainer-clean::
# 	-rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core


# include ../Makefile
