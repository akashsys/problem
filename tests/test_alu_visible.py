import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def visible_init(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    dut.start.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.opcode.value = 0
    dut.diss_clk.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1

    for _ in range(2):
        await RisingEdge(dut.clk)

    dut.diss_clk.value = 1

    for _ in range(2):
        await RisingEdge(dut.clk)


def test_visible_runner():
    import os
    from pathlib import Path
    from cocotb_tools.runner import get_runner

    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "sources" / "alu.v",
        proj_path / "sources" / "alu_clk_off.v",
        proj_path / "sources" / "top.v",
    ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="top",
        always=True,
    )

    runner.test(
        hdl_toplevel="top",
        test_module="visible",
    )
