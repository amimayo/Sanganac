import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_control_op(dut):

    # Test generation of signals by Control Unit

    # Test ALU signals

    dut.opcode.value = 0b0110011 # R-Type
    dut.funct7.value  = 0b0000001 # M-Type
    dut.funct3.value = 0b000 # MUL
    await Timer(1, unit="ns")
    assert dut.alu_src_a.value == 0, "ALU First Input NOT rs1 wrong"
    assert dut.alu_src_b.value == 0, "ALU Second Input NOT rs2 for R-Type wrong"
    assert int(dut.alucode.value) == 0x3, "MUL Alucode 8'd3 NOT equal wrong"
    assert dut.is_jump.value == 0, "is_jump for R-type wrong"
    assert dut.is_b_instr.value == 0, "is_b_instr for R-type wrong"
    assert dut.is_j_instr.value == 0, "is_j_instr for R-type wrong"

    # Test U-Type Signals

    dut.opcode.value = 0b0110111 # LUI
    await Timer(1, unit="ns")
    assert dut.alu_src_a.value == 0, "ALU First Input NOT rs1 so LUI Not selected wrong"
    assert dut.alu_src_b.value == 1, "ALU Second Input NOT imm_ext wrong"
    assert dut.wr_en_mem.value == 0, "wr_en_mem NOT 0 for LUI wrong as LUI should not write to memory"
    assert int(dut.alucode.value) == 0x1, "ADD NOT selected wrong"

    # Test B-Type Signals

    dut.opcode.value = 0b1100011 # B-Type
    await Timer(1, unit="ns")
    assert dut.alu_src_a.value == 0, "ALU First Input NOT rs1 wrong"
    assert dut.alu_src_b.value == 0, "ALU Second Input NOT rs2 wrong"
    assert dut.is_b_instr.value == 1, "is_b_instr NOT 1 for B-Type wrong"

    # Test J-Type Signals

    dut.opcode.value = 0b1100111 # JALR
    await Timer(1, unit="ns")
    assert dut.alu_src_a.value == 0, "ALU First Input NOT rs1 wrong"
    assert dut.alu_src_b.value == 0, "ALU Second Input NOT rs2 wrong"
    assert dut.is_jump.value == 1, "is_jump NOT 1 for J-Type wrong"
    assert dut.is_j_instr.value == 1, "is_j_instr NOT 1 for JALR wrong"
    assert dut.wb_sel.value == 0b10, "wb_sel NOT 2'b10 for J-Type wrong"

    # Test LOAD Signals

    dut.opcode.value = 0b0000011 # LOAD
    await Timer(1, unit="ns")
    assert dut.alu_src_a.value == 0, "ALU First Input NOT rs1 wrong"
    assert dut.alu_src_b.value == 1, "ALU Second Input NOT imm_ext for LOAD wrong"
    assert dut.read_en_mem.value == 1, "read_en_mem NOT 1 for LOAD wrong"
    assert dut.wb_sel.value == 0b01, "wb_sel NOT 2'b01 for LOAD wrong"

    # Test CSR Signals

    dut.opcode.value = 0b1110011 # CSR
    dut.funct3.value = 0b000
    dut.csr_addr.value = 0x302 # MRET
    await Timer(1, unit="ns")
    assert dut.mret_take.value == 1, "mret_take NOT 1 for MRET wrong"
    assert dut.is_jump.value == 1, "is_jump NOT 1 for MRET wrong"
    assert dut.trap_cause.value == 0x0, "trap_cause NOT 32'b0 for MRET wrong"

    dut.opcode.value = 0b1110011
    dut.funct3.value = 0b101 # CSRRWI
    await Timer(1, unit="ns")
    assert dut.csr_op.value == 0b00, "csr_op NOT 2'b00 for CSSRWI wrong"
    assert dut.csr_wr_en.value == 1, "csr_wr_en NOT 1 for CSRRWI wrong"
    assert dut.csr_read_en.value == 1, "csr_read_en NOT 1 for CSRRWI wrong"
    assert dut.wb_sel.value == 0b11, "wb_sel NOT 2'b11 for CSR wrong"