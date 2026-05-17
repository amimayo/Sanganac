import os
import glob
from cocotb_test.simulator import run

TEST_DIR = os.path.dirname(os.path.abspath(__file__))
RTL_DIR = os.path.join(TEST_DIR, "..", "rtl")

all_rtl_files = glob.glob(os.path.join(RTL_DIR, "*.v"))

# ALU Unit Tests
def test_alu_op():
    run(
        verilog_sources=[os.path.join(RTL_DIR, "alu.v")],
        toplevel="ALU",          
        module="test_alu",       
        simulator="icarus",
        timescale="1ns/1ps"
    )

# CSR Subsystem Tests
def test_csr_module():
    run(
        verilog_sources=[os.path.join(RTL_DIR, "csr.v")],
        toplevel="CSR",          
        module="test_csr",       
        simulator="icarus",
        timescale="1ns/1ps"
    )

# Memory & Masking Unit Tests
def test_memory_logic():
    run(
        verilog_sources=[os.path.join(RTL_DIR, "control.v")], 
        toplevel="CONTROL_UNIT", 
        module="test_mem",       
        simulator="icarus",
        timescale="1ns/1ps"
    )

# Control Flow Unit Tests
def test_control_logic():
    run(
        verilog_sources=[os.path.join(RTL_DIR, "control.v")],
        toplevel="CONTROL_UNIT", 
        module="test_control",   
        simulator="icarus",
        timescale="1ns/1ps"
    )

# Full Core Test
def test_full_system():
    run(
        verilog_sources=all_rtl_files,
        toplevel="TOP",          
        module="test_core",      
        simulator="icarus",
        timescale="1ns/1ps"
    )