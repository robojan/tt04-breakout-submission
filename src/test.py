import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
import pytest


async def start(dut):
    # Set initial input values
    dut.rst_n.value = 1
    dut.ena.value = 1
    dut.btn_left.value = 0
    dut.btn_right.value = 0
    dut.btn_select.value = 0
    dut.sck.value = 0
    dut.ss.value = 1
    dut.mosi.value = 0

    clock = Clock(dut.clk, 39722, units="ps")  # Create a 25.175MHz clock on port clk
    cocotb.start_soon(clock.start())  # Start the clock

    await ClockCycles(dut.clk, 10)  # Wait for 10 rising edges
    dut.rst_n.value = 0  # Assert the reset_n signal
    await ClockCycles(dut.clk, 10)  # Wait 10 clock cycles
    dut.rst_n.value = 1  # Deassert the reset_n signal
    await ClockCycles(dut.clk, 5)  # Wait 10 clock cycles

    return clock

async def wait_for_line(dut, line):
    await RisingEdge(dut.vsync)
    line_count = -33 # Back porch
    while line_count < line:
        await RisingEdge(dut.hsync)
        line_count += 1
    await ClockCycles(dut.clk, 48) # Back porch for hsync


@cocotb.test()
async def test_hfreq(dut):
    await start(dut)

    await FallingEdge(dut.hsync)
    e1 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hsync)
    e1r = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hsync)
    e2 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hsync)
    e2r = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hsync)
    e3 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hsync)
    e3r = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hsync)
    e4 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hsync)
    e4r = cocotb.utils.get_sim_time(units="ns")

    t1 = e2 - e1
    w1 = e1r - e1
    t2 = e3 - e2
    w2 = e2r - e2
    t3 = e4 - e3
    w3 = e3r - e3
    w4 = e4r - e4

    assert t1 == pytest.approx(t2)
    assert t2 == pytest.approx(t3)
    assert t1 == pytest.approx(31777.600) # 31.469kHz

    assert w1 == pytest.approx(w2)
    assert w2 == pytest.approx(w3)
    assert w3 == pytest.approx(w4)
    assert w1 == pytest.approx(96 * 39.722) # 96 pixels

@cocotb.test()
async def test_vfreq(dut):
    await start(dut)

    await FallingEdge(dut.vsync)
    e1 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.vsync)
    e1r = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.vsync)
    e2 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.vsync)
    e2r = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.vsync)
    e3 = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.vsync)
    e3r = cocotb.utils.get_sim_time(units="ns")

    t1 = e2 - e1
    t2 = e3 - e2
    w1 = e1r - e1
    w2 = e2r - e2
    w3 = e3r - e3

    assert t1 == pytest.approx(t2)
    assert t1 == pytest.approx(16683240) # 59.94Hz

    assert w1 == pytest.approx(w2)
    assert w2 == pytest.approx(w3)
    assert w1 == pytest.approx(2 * 39.722 * 800) # 2 lines

@cocotb.test()
async def test_hblank(dut):
    await start(dut)

    await RisingEdge(dut.hblank)
    e1 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hblank)
    e1f = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hblank)
    e2 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hblank)
    e2f = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hblank)
    e3 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hblank)
    e3f = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.hblank)
    e4 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.hblank)
    e4f = cocotb.utils.get_sim_time(units="ns")

    t1 = e2 - e1
    t2 = e3 - e2
    t3 = e4 - e3
    w1 = e1f - e1
    w2 = e2f - e2
    w3 = e3f - e3
    w4 = e4f - e4

    assert t1 == pytest.approx(t2)
    assert t2 == pytest.approx(t3)
    assert t1 == pytest.approx(31777.600) # 31.469kHz

    assert w1 == pytest.approx(160 * 39.722)
    assert w2 == pytest.approx(w1)
    assert w3 == pytest.approx(w1)
    assert w4 == pytest.approx(w1)

@cocotb.test()
async def test_vblank(dut):
    await start(dut)

    await RisingEdge(dut.vblank)
    e1 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.vblank)
    e1f = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.vblank)
    e2 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.vblank)
    e2f = cocotb.utils.get_sim_time(units="ns")
    await RisingEdge(dut.vblank)
    e3 = cocotb.utils.get_sim_time(units="ns")
    await FallingEdge(dut.vblank)
    e3f = cocotb.utils.get_sim_time(units="ns")

    t1 = e2 - e1
    t2 = e3 - e2
    w1 = e1f - e1
    w2 = e2f - e2
    w3 = e3f - e3

    assert t1 == pytest.approx(t2)
    assert t1 == pytest.approx(16683240)

    assert w1 == pytest.approx(45 * 39.722 * 800)
    assert w2 == pytest.approx(w1)
    assert w3 == pytest.approx(w1)

@cocotb.test()
async def test_move_paddle_left(dut):
    await start(dut)

    await wait_for_line(dut, 458)
    t1 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of line time: {t1}")
    await ClockCycles(dut.clk, 16) # Skip the border
    await RisingEdge(dut.vga_r0) # Wait until the paddle
    t2 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of paddle time: {t2}")
    pos_paddle1 = t2 - t1
    dut._log.info(f"paddle time: {pos_paddle1}")

    dut.btn_left.value = 1

    await wait_for_line(dut, 458)
    t1 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of line time: {t1}")
    await ClockCycles(dut.clk, 16) # Skip the border
    await RisingEdge(dut.vga_r0) # Wait until the paddle
    t2 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of paddle time: {t2}")
    pos_paddle2 = t2 - t1
    dut._log.info(f"paddle time: {pos_paddle2}")

    
    assert pos_paddle2 < pos_paddle1

@cocotb.test()
async def test_move_paddle_right(dut):
    await start(dut)

    await wait_for_line(dut, 458)
    t1 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of line time: {t1}")
    await ClockCycles(dut.clk, 16)
    await RisingEdge(dut.vga_r0)
    t2 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of paddle time: {t2}")
    pos_paddle1 = t2 - t1
    dut._log.info(f"paddle time: {pos_paddle1}")

    dut.btn_right.value = 1

    await wait_for_line(dut, 458)
    t1 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of line time: {t1}")
    await ClockCycles(dut.clk, 16)
    await RisingEdge(dut.vga_r0)
    t2 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of paddle time: {t2}")
    pos_paddle2 = t2 - t1
    dut._log.info(f"paddle time: {pos_paddle2}")

    assert pos_paddle2 > pos_paddle1

@cocotb.test()
async def test_dont_move_paddle(dut):
    await start(dut)

    await wait_for_line(dut, 458)
    t1 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of line time: {t1}")
    await ClockCycles(dut.clk, 16)
    await RisingEdge(dut.vga_r0)
    t2 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of paddle time: {t2}")
    pos_paddle1 = t2 - t1
    dut._log.info(f"paddle time: {pos_paddle1}")

    await RisingEdge(dut.vsync)

    await wait_for_line(dut, 458)
    t1 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of line time: {t1}")
    await ClockCycles(dut.clk, 16)
    await RisingEdge(dut.vga_r0)
    t2 = cocotb.utils.get_sim_time(units="ns")
    dut._log.info(f"take start of paddle time: {t2}")
    pos_paddle2 = t2 - t1
    dut._log.info(f"paddle time: {pos_paddle2}")

    assert pos_paddle2 == pytest.approx(pos_paddle1)