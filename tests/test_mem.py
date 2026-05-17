import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_mem_op(dut):
    
    # Test mem_mask generation and LUI/AUIPC bypassing
    
    # Test LUI (Opcode 0110111)
    dut.opcode.value = 0b0110111
    dut.imm_ext.value = 0xABCDE000
    await Timer(1, units="ns")
    assert int(dut.out.value) == 0xABCDE000, "LUI Failed"
    assert dut.wr_en_mem.value == 0, "LUI should not write memory"
    
    # Test AUIPC (Opcode 0010111)
    dut.opcode.value = 0b0010111
    dut.pc.value = 0x00000010
    dut.imm_ext.value = 0x00001000
    await Timer(1, units="ns")
    assert int(dut.out.value) == 0x00001010, "AUIPC Failed"

    # Test Store Byte (SB) Masking
    dut.opcode.value = 0b0100011 # S-Type
    dut.funct3.value = 0b000     # SB
    
    # Writing to address ending in 01 (byte offset 1)
    dut.rd_output.value = 0x00000001 
    await Timer(1, units="ns")
    assert int(dut.mem_mask.value) == 0b0010, "SB Masking failed for offset 1"
    
    # Writing to address ending in 10 (byte offset 2)
    dut.rd_output.value = 0x00000002 
    await Timer(1, units="ns")
    assert int(dut.mem_mask.value) == 0b0100, "SB Masking failed for offset 2"

    # Test Store Halfword (SH) Masking
    dut.funct3.value = 0b001     # SH
    dut.rd_output.value = 0x00000002 # Offset 2
    await Timer(1, units="ns")
    assert int(dut.mem_mask.value) == 0b1100, "SH Masking failed for offset 2"