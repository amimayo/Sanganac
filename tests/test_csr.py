import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_csr_op(dut):

    #Test CSRRW, CSRRS, CSRRC operations
    
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    
    dut.reset.value = 1
    dut.csr_wr_en.value = 0
    dut.csr_read_en.value = 0
    dut.trap_take.value = 0
    dut.mret_take.value = 0
    
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    # Test CSRRW (Write) to MTVEC (Address 0x305)
    dut.csr_addr.value = 0x305
    dut.csr_op.value = 0b00     # CSRRW (Write)
    dut.csr_wr_data.value = 0x100
    dut.csr_wr_en.value = 1
    
    await RisingEdge(dut.clk) 
   
    await Timer(1, unit="ns") 
    assert int(dut.trap_pc.value) == 0x100, f"Trap PC Forwarding failed! Expected 0x100, got {hex(int(dut.trap_pc.value))}"
    
    # Test CSRRS (Set Bits) on MTVEC
    dut.csr_op.value = 0b01     # CSRRS (Set)
    dut.csr_wr_data.value = 0x011 # Set bit 0 and bit 4
    await RisingEdge(dut.clk)
    
    dut.csr_wr_en.value = 0
    dut.csr_read_en.value = 1
    await Timer(1, unit="ns")
    
    # Original was 0x100. Setting 0x011 makes it 0x111
    assert int(dut.csr_read_data.value) == 0x111, f"CSRRS failed. Got {hex(int(dut.csr_read_data.value))}"
    
    # Test CSRRC (Clear Bits)
    dut.csr_wr_en.value = 1
    dut.csr_op.value = 0b11       # CSRRC (Clear)
    dut.csr_wr_data.value = 0x010 # Clear bit 4
    await RisingEdge(dut.clk)
    
    dut.csr_wr_en.value = 0
    await Timer(1, unit="ns")
    
    # Original was 0x111. Clearing bit 4 (0x010) makes it 0x101
    assert int(dut.csr_read_data.value) == 0x101, f"CSRRC failed. Got {hex(int(dut.csr_read_data.value))}"
    
    dut._log.info("CSR Read/Write, Set, and Clear logic perfectly verified!")