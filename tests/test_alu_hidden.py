import cocotb
from cocotb.triggers import Timer, RisingEdge


async def generate_clock(dut):
    """Generate clock pulses."""
    for _ in range(2000):
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")


async def reset_dut(dut):
    """Reset the DUT."""
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.opcode.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await Timer(20, units="ns")


# -------------------------------------------------------
# SINGLE-CYCLE OPERATIONS
# -------------------------------------------------------

@cocotb.test()
async def test_add(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 10
    dut.B.value = 5
    dut.opcode.value = 0  # ADD
    dut.start.value = 1
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(20, units="ns")

    dut._log.info(f"ADD result = {int(dut.result.value)}")
    assert int(dut.result.value) == 15, "ADD failed"


@cocotb.test()
async def test_sub(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 20
    dut.B.value = 7
    dut.opcode.value = 1  # SUB
    dut.start.value = 1
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(20, units="ns")

    dut._log.info(f"SUB result = {int(dut.result.value)}")
    assert int(dut.result.value) == 13, "SUB failed"


@cocotb.test()
async def test_and(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 0xF0F0
    dut.B.value = 0x0FF0
    dut.opcode.value = 2  # AND
    dut.start.value = 1
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(20, units="ns")

    assert int(dut.result.value) == (0xF0F0 & 0x0FF0), "AND failed"


@cocotb.test()
async def test_or(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 0x00F0
    dut.B.value = 0x0F00
    dut.opcode.value = 3  # OR
    dut.start.value = 1
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(20, units="ns")

    assert int(dut.result.value) == (0x00F0 | 0x0F00), "OR failed"


@cocotb.test()
async def test_xor(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 0xAAAA
    dut.B.value = 0x5555
    dut.opcode.value = 4  # XOR
    dut.start.value = 1
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(20, units="ns")

    assert int(dut.result.value) == (0xAAAA ^ 0x5555), "XOR failed"


@cocotb.test()
async def test_sll(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 1
    dut.B.value = 4
    dut.opcode.value = 6  # SLL
    dut.start.value = 1
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(20, units="ns")

    assert int(dut.result.value) == (1 << 4), "SLL failed"


# -------------------------------------------------------
# MULTI-CYCLE OPERATIONS
# -------------------------------------------------------

@cocotb.test()
async def test_mul(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 12
    dut.B.value = 10
    dut.opcode.value = 8  # MUL
    dut.start.value = 1

    await Timer(10, units="ns")
    dut.start.value = 0

    # MUL takes 5 cycles → 5 * 10ns = 50ns
    await Timer(200, units="ns")

    dut._log.info(f"MUL result = {int(dut.result.value)}")
    assert int(dut.result.value) == 120, "MUL failed"


@cocotb.test()
async def test_div(dut):
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 100
    dut.B.value = 4
    dut.opcode.value = 9  # DIV
    dut.start.value = 1

    await Timer(10, units="ns")
    dut.start.value = 0

    # DIV takes 9 cycles → 9 * 10ns
    await Timer(300, units="ns")

    dut._log.info(f"DIV result = {int(dut.result.value)}")
    assert int(dut.result.value) == 25, "DIV failed"


# -------------------------------------------------------
# RUNNER (just like your RC5 example)
# -------------------------------------------------------

def test_alu_runner():
    import os
    from pathlib import Path
    from cocotb_tools.runner import get_runner

    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "sources" / "top.v"
    ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="top",
        always=True,
    )

    runner.test(
        hdl_toplevel="top",
        test_module="test_alu_hidden"
    )
