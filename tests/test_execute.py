import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_execute_op(dut):