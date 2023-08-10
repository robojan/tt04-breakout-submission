SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# normal simulation
ifneq ($(GATES),yes)

# this is the only part you should need to modify:
VERILOG_SOURCES += $(PWD)/tb.v \
	$(PWD)/ball_painter.v \
	$(PWD)/block_state.v \
	$(PWD)/blocks_painter.v \
	$(PWD)/border_painter.v \
	$(PWD)/breakout.v \
	$(PWD)/cells.v \
	$(PWD)/game_logic.v \
	$(PWD)/lives_painter.v \
	$(PWD)/paddle_painter.v \
	$(PWD)/sound_gen.v \
	$(PWD)/spi_ctrl.v \
	$(PWD)/spi_if.v \
	$(PWD)/synchronizer.v \
	$(PWD)/tt_um_robojan_top.v \
	$(PWD)/vga_timing.v \
	$(PWD)/video_mux.v

else

# gate level simulation requires some extra setup, you shouldn't need to touch this
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/tb.v $(PWD)/gate_level_netlist.v
endif

TOPLEVEL = tb

MODULE = test

include $(shell cocotb-config --makefiles)/Makefile.sim