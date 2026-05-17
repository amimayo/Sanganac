import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_control_op(dut):

    # Test generation of signals by Control Unit

    # Test is_jump and jump_pc logic for B-Type and J-Type
    dut.opcode.value = 0b1100011 # B-Type Opcode
    dut.pc.value = 0x100
    dut.imm_ext.value = 0x20     # Jump target = 0x120
    
    # Test BEQ (funct3 = 000)
    dut.funct3.value = 0b000
    dut.rs1_in.value = 5
    dut.rs2_in.value = 5
    await Timer(1, units="ns")
    assert dut.is_jump.value == 1, "BEQ should jump"
    assert int(dut.jump_pc.value) == 0x120, "BEQ target wrong"
    
    dut.rs2_in.value = 6
    await Timer(1, units="ns")
    assert dut.is_jump.value == 0, "BEQ should NOT jump"

    # Test BLT (Signed Less Than) vs BLTU (Unsigned Less Than)
    dut.rs1_in.value = 0xFFFFFFFF # -1 Signed, Max Unsigned
    dut.rs2_in.value = 0x00000001 # 1
    
    # BLT (funct3 = 100): -1 < 1 (Should Jump)
    dut.funct3.value = 0b100
    await Timer(1, units="ns")
    assert dut.is_jump.value == 1, "BLT failed signed comparison"
    
    # BLTU (funct3 = 110): 0xFFFFFFFF < 1 (Should NOT Jump)
    dut.funct3.value = 0b110
    await Timer(1, units="ns")
    assert dut.is_jump.value == 0, "BLTU failed unsigned comparison"

    # Test JALR (Opcode 1100111)
    dut.opcode.value = 0b1100111
    dut.rs1_in.value = 0x200
    dut.imm_ext.value = 0x14
    await Timer(1, units="ns")
    assert dut.is_jump.value == 1, "JALR should always jump"
    assert int(dut.jump_pc.value) == 0x214, "JALR target wrong"
    # LSB of JALR must be set to 0 (tested via jump_pc calc: (rs1_in + imm_ext) & ~1)
    
    dut.rs1_in.value = 0x200
    dut.imm_ext.value = 0x15 # Odd immediate
    await Timer(1, units="ns")
    assert int(dut.jump_pc.value) == 0x214, "JALR LSB zeroing failed"