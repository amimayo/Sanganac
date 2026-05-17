import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def test_full_core(dut):

    # Test the hex file and verify final state
    
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    
    max_cycles = 1000
    cycles = 0
    
    dut._log.info("Starting Core Execution...")
    
    # Monitor the CPU execution
    while cycles < max_cycles:
        await RisingEdge(dut.clk)
        cycles += 1
        
        current_pc = int(dut.sanganac.pc_current.value) 
            
        if current_pc == 0x68: # HALT / Infinite Loop Address
            dut._log.info(f"Program successfully HALTED at cycle {cycles}")
            break
            
    assert cycles < max_cycles, f"Simulation Timeout! Reached {max_cycles} cycles."
    
    expected_registers = {
        0: 0x00000000,  # Hardwired zero
        1: 0x0000000A,  # 10
        2: 0x00000003,  # 3
        3: 0x0000000D,  # 13 (ADD X1, X2)
        4: 0x00000007,  # 7  (SUB X1, X2)
        5: 0x00000070,  # 112 (Handler Address)
        6: 0x00000003,  # 3  (DIV X1, X2)
        7: 0x00000001,  # 1  (REM X1, X2)
        8: 0x00000000,  # 0  (SRL X7, X2)
        9: 0x0000001E,  # 30 (LW from memory)
        10: 0xABCDE000, # LUI address
        11: 0x0000001E, # 30 (LBU from trap handler)
        12: 0x0000001E, # 30 (Branch success)
        13: 0x0000000D, # 13 (JALR success)
        14: 0x00000000, # Unused
        15: 0x00000054, # 84 (JALR target)
        16: 0x00000001  # 1 (Trap Counter incremented)
    }

    dut._log.info("Starting register verification (X0-X16)...")
    
    failed_registers = []

    for reg_num, expected_val in expected_registers.items():
        
        # Read the values
        actual_val = int(dut.sanganac.regfile.registerfile[reg_num].value)
        
        if actual_val != expected_val:
            failed_registers.append(
                f"X{reg_num} | Expected: {hex(expected_val)}, Got: {hex(actual_val)}"
            )

    if failed_registers:
        dut._log.error("Program Register Test Failed :")
        for fail_msg in failed_registers:
            dut._log.error(fail_msg)
        assert False, "One or more registers contained the wrong value."
    else:
        dut._log.info("All Registers match correct values !")
            