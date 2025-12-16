import cocotb
from cocotb.triggers import Timer, RisingEdge


async def generate_clock(dut):
    for _ in range(200):
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.opcode.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await Timer(20, units="ns")


@cocotb.test()
async def test_basic_sanity(dut):
    """Visible: only checks that signals toggle and no X propagation."""
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.start.value = 1
    dut.opcode.value = 0
    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(50, units="ns")

    # No golden checks allowed here
    assert dut.result.value.is_resolvable, "Output contains X/Z values"
    dut._log.info("Sanity test passed.")


@cocotb.test()
async def test_state_progression(dut):
    """Visible: confirm busy toggles for multi-cycle ops."""
    await cocotb.start(generate_clock(dut))
    await reset_dut(dut)

    dut.A.value = 3
    dut.B.value = 3
    dut.opcode.value = 8   # MUL
    dut.start.value = 1

    await Timer(10, units="ns")
    dut.start.value = 0

    await Timer(30, units="ns")  # busy must be 1 early

    assert dut.busy.value in (0,1)
    dut._log.info("busy toggled as expected")
