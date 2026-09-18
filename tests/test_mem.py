import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_mem_op(dut):
    
    # Test mem_mask generation
    
    # Test LB

    dut.funct3.value = 0b100
    dut.wr_en_mem.value = 0
    dut.read_en_mem.value = 1
    dut.addr.value = 0x1
    await Timer(1, units="ns")
    assert dut.load_unsigned.value == 1, "load_unsigned Not 1 for funct3 0b100"
    assert dut.mem_mask.value == 0b0010, "mem_mask NOT 4'b0010 for byte_sel 2'b01 wrong"

    # Test LH

    dut.funct3.value = 0b001
    dut.wr_en_mem.value = 0
    dut.read_en_mem.value = 1
    dut.addr.value = 0x2
    await Timer(1, units="ns")
    assert dut.load_unsigned.value == 0, "load_unsigned Not 0 for funct3 0b001"
    assert dut.mem_mask.value == 0b1100, "mem_mask NOT 4'b1100 for byte_sel 2'b10 wrong"

    # Test LW

    dut.funct3.value = 0b110
    dut.wr_en_mem.value = 0
    dut.read_en_mem.value = 1
    dut.addr.value = 0x3
    await Timer(1, units="ns")
    assert dut.load_unsigned.value == 1, "load_unsigned Not 1 for funct3 0b110"
    assert dut.mem_mask.value == 0b1111, "mem_mask NOT 4'b1111 for byte_sel 2'b10 wrong"
