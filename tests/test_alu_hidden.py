import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock


async def start_clock(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.opcode.value = 0
    dut.alu_pwr_en.value = 1
    dut.iso_en.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(2):
        await RisingEdge(dut.clk)


async def run_op(dut, A, B, opcode, cycles):
    dut.A.value = A
    dut.B.value = B
    dut.opcode.value = opcode
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0
    for _ in range(cycles):
        await RisingEdge(dut.clk)


@cocotb.test()
async def test_add(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await run_op(dut, 10, 5, 0, 2)
    assert int(dut.result.value) == 15


@cocotb.test()
async def test_sub(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await run_op(dut, 20, 7, 1, 2)
    assert int(dut.result.value) == 13


@cocotb.test()
async def test_and(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await run_op(dut, 0xF0F0, 0x0FF0, 2, 2)
    assert int(dut.result.value) == (0xF0F0 & 0x0FF0)


@cocotb.test()
async def test_mul(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await run_op(dut, 12, 10, 8, 7)
    assert int(dut.result.value) == 120


@cocotb.test()
async def test_div(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await run_op(dut, 100, 4, 9, 11)
    assert int(dut.result.value) == 25

@cocotb.test()
async def test_sll_operation(dut):
    await start_clock(dut)
    await reset_dut(dut)

    await run_op(dut, 1, 4, 6, 2)
    assert int(dut.result.value) == (1 << 4)


@cocotb.test()
async def test_clamp_is_valid_value(dut):
    await start_clock(dut)
    await reset_dut(dut)

    dut.iso_en.value = 1
    await RisingEdge(dut.clk)

    val = dut.clamp_obs.value
    assert val.is_resolvable, "Clamp is X or Z"
    assert int(val) in [0, 1], "Clamp must be 0 or 1"



@cocotb.test()
async def test_iso_en_clamps_output(dut):
    await start_clock(dut)
    await reset_dut(dut)

    await run_op(dut, 9, 6, 0, 2)   # operation completes

    dut.iso_en.value = 1
    await RisingEdge(dut.clk)

    assert int(dut.result.value) == int(dut.clamp_obs.value), \
        "Result does not match clamp on iso_en"



@cocotb.test()
async def test_power_down_clamps_output(dut):
    await start_clock(dut)
    await reset_dut(dut)

    await run_op(dut, 8, 2, 0, 2)   # operation completes

    dut.alu_pwr_en.value = 0
    await RisingEdge(dut.clk)

    assert int(dut.result.value) == int(dut.clamp_obs.value), \
        "Result does not match clamp on power-down"



def test_alu_runner():
    import os
    from pathlib import Path
    from cocotb_tools.runner import get_runner

    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "sources" / "alu.v",
        proj_path / "sources" / "aon_block.v",
        proj_path / "sources" / "top.v",
    ]

    runner = get_runner(sim)
    runner.build(sources=sources, hdl_toplevel="top", always=True)
    runner.test(hdl_toplevel="top", test_module="test_alu_hidden")
