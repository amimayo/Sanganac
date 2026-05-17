import cocotb
from cocotb.triggers import Timer
import random
import itertools


def to_signed(val, bits=32):
    
    mask = (1 << bits) - 1
    val = val & mask
    if val & (1 << (bits - 1)):
        return val - (1 << bits)
    return val

def trunc_div(a, b):
   
    if b == 0: return -1
    if a == -2147483648 and b == -1: return -2147483648
    res = abs(a) // abs(b)
    if (a < 0) ^ (b < 0):
        res = -res
    return res

def trunc_rem(a, b):
   
    if b == 0: return a
    if a == -2147483648 and b == -1: return 0
    return a - trunc_div(a, b) * b

def alu_model(rs1, rs2, alucode):
  
    rs1_u = rs1 & 0xFFFFFFFF
    rs2_u = rs2 & 0xFFFFFFFF
    rs1_s = to_signed(rs1_u, 32)
    rs2_s = to_signed(rs2_u, 32)
    shamt = rs2_u & 0x1F

    if alucode == 1:   res = rs1_u + rs2_u                  # ADD
    elif alucode == 2: res = rs1_u - rs2_u                  # SUB
    elif alucode == 3: res = rs1_u * rs2_u                  # MUL
    elif alucode == 4:                                      # DIV (Signed)
        if rs2_u == 0: res = -1
        else: res = trunc_div(rs1_s, rs2_s)
    elif alucode == 5:                                      # REM (Signed)
        if rs2_u == 0: res = rs1_u 
        else: res = trunc_rem(rs1_s, rs2_s)
    elif alucode == 6: res = rs1_u & rs2_u                  # AND
    elif alucode == 7: res = rs1_u | rs2_u                  # OR
    elif alucode == 8: res = rs1_u ^ rs2_u                  # XOR
    elif alucode == 9: res = rs1_u << shamt                 # SLL
    elif alucode == 10: res = rs1_u >> shamt                # SRL
    elif alucode == 11: res = rs1_s >> shamt                # SRA (Sign-extended)
    elif alucode == 12:                                     # DIVU (Unsigned)
        if rs2_u == 0: res = -1
        else: res = rs1_u // rs2_u
    elif alucode == 13:                                     # REMU (Unsigned)
        if rs2_u == 0: res = rs1_u
        else: res = rs1_u % rs2_u
    elif alucode == 14: res = 1 if rs1_s < rs2_s else 0     # SLT
    elif alucode == 15: res = 1 if rs1_u < rs2_u else 0     # SLTU
    elif alucode == 16: res = rs1_s * rs2_s                 # MULH
    elif alucode == 17: res = rs1_s * rs2_u                 # MULHSU
    else: res = 0

    return res & 0xFFFFFFFFFFFFFFFF


@cocotb.test()
async def test_alu_op(dut):

    # Test all ALU operations against edge cases and random cases.
    
    edge_cases = [0x00000000, 0x00000001, 0xFFFFFFFF, 0x7FFFFFFF, 0x80000000]
    
    random_cases = [random.randint(0, 0xFFFFFFFF) for _ in range(50)]
    
    test_pool = edge_cases + random_cases
    
    op_names = {
        1: "ADD", 2: "SUB", 3: "MUL", 4: "DIV", 5: "REM",
        6: "AND", 7: "OR", 8: "XOR", 9: "SLL", 10: "SRL",
        11: "SRA", 12: "DIVU", 13: "REMU", 14: "SLT",
        15: "SLTU", 16: "MULH", 17: "MULHSU"
    }

    tests_run = 0
    dut._log.info("Starting ALU Edge-Case and Random Case Test...")

    for a, b in itertools.product(test_pool, repeat=2):
        for alucode in range(1, 18):
            
            dut.rs1.value = a
            dut.rs2.value = b
            dut.alucode.value = alucode
            
            await Timer(1, unit="ns") 
            
            actual = int(dut.rd.value)
            expected = alu_model(a, b, alucode)
            
            assert actual == expected, \
                f"\nALU {op_names[alucode]} FAILED!\n" \
                f"rs1:  {hex(a)}\n" \
                f"rs2:  {hex(b)}\n" \
                f"Got:  {hex(actual)}\n" \
                f"Exp:  {hex(expected)}"
            
            tests_run += 1

    dut._log.info(f"ALU passed! Successfully ran {tests_run} automated verifications.")