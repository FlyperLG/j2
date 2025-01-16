import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.binary import BinaryValue

INSN = { 
    "LITERAL":          0b1000000000000000,
    "JUMP":             0b0000000000010000,
    "CALL":             0b0100000000100000,
    "COND_JUMP":        0b0010000001000000,
    "TOP":              0b0110000000000000,
    "SEC":              0b0110000100000000,
    "ADD":              0b0110001000010001,
    "AND":              0b0110001100000000,
    "OR":               0b0110010000000000,
    "XOR":              0b0110010100000000,
    "INVERT":           0b0110011000000000,
    "EQUAL":            0b0110011100000000,
    "SMALLER_SIGNED":   0b0110100000000000,
    "RSHIFT":           0b0110100100000000,
    "LSHIFT":           0b0110101000000000,
    "RETURN":           0b0110101100000000,
    "MEM_DIN":          0b0110110000000000,
    "IO_DIN":           0b0110110100000000,
    "DEPTH":            0b0110111000000000,
    "SMALLER":          0b0110111100000000,
    "NO_INSN":          BinaryValue(value="x", n_bits=16),
    "ADD_TO_MEM":       0b0110001000110000,
    "ADD_TO_IO":        0b0110001001000000,
}


async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(10):
        dut.clk.value = 0
        await Timer(1, units="sec")
        dut.clk.value = 1
        await Timer(1)

# @cocotb.test()
# async def testcase_template(dut):
#     """Test DESCRIPTION"""
#     await cocotb.start(generate_clock(dut))  # Generate clock

#     # Initalize TESTCASE
#     dut.resetq.value = 0
#     await RisingEdge(dut.clk)
#     await FallingEdge(dut.clk)

#     # Check SOMETHING
#     assert dut.resetq.value == 0, f"Expected TESTVAR to be 0, got {dut.resetq.value}"
#     dut._log.info("my_signal_1 is %s", dut.my_signal_1.value)

@cocotb.test()
async def testcase_alu_basic(dut):
    """Test basic ALU T & N Operation"""
    await cocotb.start(generate_clock(dut))  # Generate clock

    dut.insn.value = INSN["TOP"]
    dut.st0.value = 5
    await RisingEdge(dut.clk)  # Trigger Operation
    await FallingEdge(dut.clk)  # Any Await would work -> st0 = st0N wird NACH RisingEdge zugewiesen
    assert dut.st0.value == 5, f"Expected st0 to still be 5 aftere T, got {dut.st0.value}"

    dut.insn.value = INSN["SEC"]
    dut.st1.value = 10
    await RisingEdge(dut.clk) 
    await FallingEdge(dut.clk)  
    assert dut.st0.value == 10, f"Expected st0 to be 10 after N, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_add(dut):
    """Test ADD ALU Operation"""
    await cocotb.start(generate_clock(dut))

    dut.insn.value = INSN["ADD"]
    dut.st0.value = 5
    dut.st1.value = 3
    await RisingEdge(dut.clk) 
    await FallingEdge(dut.clk)
    assert dut.st0.value == 8, f"Expected st0 to be 8 after ADD, got {dut.st0.value}"


@cocotb.test()
async def testcase_alu_and(dut):
    """Test AND ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["AND"]
    dut.st0.value = 0b1101
    dut.st1.value = 0b1011
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 0b1001, f"Expected st0 to be 0b1001 after AND, got {dut.st0.value}"


@cocotb.test()
async def testcase_alu_or(dut):
    """Test OR ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["OR"]
    dut.st0.value = 0b1101
    dut.st1.value = 0b1011
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 0b1111, f"Expected st0 to be 0b1111 after OR, got {dut.st0.value}"


@cocotb.test()
async def testcase_alu_xor(dut):
    """Test XOR ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["XOR"]
    dut.st0.value = 0b1101
    dut.st1.value = 0b1011
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 0b0110, f"Expected st0 to be 0b0110 after XOR, got {dut.st0.value}"


@cocotb.test()
async def testcase_alu_invert(dut):
    """Test Invert ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["INVERT"]
    dut.st0.value = 0b1101
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    # Size of st0 has to be acounted for
    assert dut.st0.value == 0b11111111111111111111111111110010, f"Expected st0 to be 11111111111111111111111111110010 after Invert, got {dut.st0.value}"


@cocotb.test()
async def testcase_alu_equal(dut):
    """Test equal ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["EQUAL"]
    dut.st0.value = 5
    dut.st1.value = 5
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value != 0, f"Expected st0 to not be 0 after equal, got {dut.st0.value}"


@cocotb.test()
async def testcase_alu_smaller_signed(dut):
    """Test smaller signed ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.insn.value = INSN["SMALLER_SIGNED"]
    dut.st0.value = 5
    dut.st1.value = -5
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value != 0, f"Expected st0 to not be 0 after smaller signed, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_shift(dut):
    """Test rshift & lshift ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.insn.value = INSN["RSHIFT"]
    dut.st0.value = 1
    dut.st1.value = 2
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 1, f"Expected st0 to be 1 after rshift, got {dut.st0.value}"

    dut.insn.value = INSN["LSHIFT"]
    dut.st0.value = 1
    dut.st1.value = 2
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 4, f"Expected st0 to be 4 after lshift, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_return(dut):
    """Test return ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    # Fill return stack
    dut.rstkW.value = 1
    dut.rsp.value = 0
    dut.insn.value = 0b0110000000100100
    dut.st0.value = 73
    await RisingEdge(dut.clk)

    # Set st0 to something else
    dut.rstkW.value = 0
    dut.insn.value = INSN["TOP"]
    dut.st0.value = 100
    await RisingEdge(dut.clk)

    # Check return stack
    dut.insn.value = INSN["RETURN"]
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 73, f"Expected st0 to be 73 after return, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_mem_din(dut):
    """Test memory din ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.insn.value = INSN["MEM_DIN"]
    dut.mem_din.value = 9
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 9, f"Expected st0 to be 9 after memory data in, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_io_din(dut):
    """Test io din ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.insn.value = INSN["IO_DIN"]
    dut.io_din.value = 66
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 66, f"Expected st0 to be 66 after i/o data in, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_depth(dut):
    """Test depth ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.dstkW.value = 1
    dut.dsp.value = 0
    dut.st0.value = 49
    dut.insn.value = 0b0110000000010001

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

    dut.dstkW.value = 0
    dut.rstkW.value = 1
    dut.rsp.value = 0
    dut.insn.value = 0b0110000000100100

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

    dut.insn.value = INSN["DEPTH"]
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 35, f"Expected st0 to be 17 after depth, got {dut.st0.value}"

@cocotb.test()
async def testcase_alu_smaller(dut):
    """Test smaller ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.insn.value = INSN["SMALLER"]
    dut.st0.value = 5
    dut.st1.value = 5
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.st0.value == 0, f"Expected st0 to be 0 after smaller, got {dut.st0.value}"

@cocotb.test()
async def testcase_jump(dut):
    """Test jump operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["JUMP"]
    dut.st0.value = 0
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.pc.value == 16, f"Expected pc to jump to 16, got {dut.pc.value}"

@cocotb.test()
async def testcase_call(dut):
    """Test call operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["CALL"]
    dut.st0.value = 0
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.pc.value == 32, f"Expected pc to call to 32, got {dut.pc.value}"

@cocotb.test()
async def testcase_cond_jump(dut):
    """Test conditional jump"""
    await cocotb.start(generate_clock(dut)) 

    dut.insn.value = INSN["COND_JUMP"]
    dut.st1.value = 0
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.pc.value == 64, f"Expected pc to jump to 64, got {dut.pc.value}"

@cocotb.test()
async def testcase_no_insn(dut):
    """Test no valid instruction"""
    await cocotb.start(generate_clock(dut))  

    dut.insn.value = INSN["NO_INSN"]
    dut.dstkW.value = 0
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    xes = ("x" * 32)
    assert dut.st0.value == xes, f"Expected st0 to be x after invalid instruction, got {dut.st0.value}"

@cocotb.test()
async def testcase_data_stack(dut):
    """Test Data Stack"""
    await cocotb.start(generate_clock(dut))

    dut.dstkW.value = 1
    dut.dsp.value = 0
    dut.st0.value = 49
    dut.insn.value = 0b0110000000010001

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

    assert dut.dsp.value == 3, f"Expected dsp to be 3, got {dut.dsp.value}"
    assert dut.st1.value == 49, f"Expected st1 to be 49, got {dut.st1.value}"

@cocotb.test()
async def testcase_return_stack(dut):
    """Test Return Stack"""
    await cocotb.start(generate_clock(dut))

    dut.rstkW.value = 1
    dut.rsp.value = 0
    dut.insn.value = 0b0110000000100100

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

    assert dut.rsp.value == 2, f"Expected rsp to be 2, got {dut.resetq.value}"

@cocotb.test()
async def testcase_mem_write(dut):
    """Test Memory Write"""
    await cocotb.start(generate_clock(dut))

    dut.insn.value = INSN["ADD_TO_MEM"]
    dut.st0.value = 10
    dut.st1.value = 30

    await RisingEdge(dut.clk)

    assert dut.st1.value == 30, f"Expected st0 to be 40 got {dut.st0.value}"
    assert dut.dout.value == 30, f"Expected dout to be 40 got {dut.dout.value}"
    assert dut.mem_wr.value != 0, f"Expected mem_wr not be 0 got {dut.mem_wr.value}"
    assert dut.mem_addr.value == 40, f"Expected dout to be mem_addr to be 130 got {dut.mem_addr.value}"

@cocotb.test()
async def testcase_io_write(dut):
    """Test IO Write"""
    await cocotb.start(generate_clock(dut))

    dut.insn.value = INSN["ADD_TO_IO"]
    dut.st0.value = 20
    dut.st1.value = 60

    await RisingEdge(dut.clk)

    assert dut.dout.value == 60, f"Expected dout to be 60, got {dut.dout.value}"
    assert dut.io_wr.value != 0, f"Expected io_wr not be 0 , got {dut.mem_wr.value}"
    assert dut.mem_addr.value == 80, f"Expected mem_addr to be 140, got {dut.mem_addr.value}"

@cocotb.test()
async def test_reset(dut):
    """Test Reset"""
    await cocotb.start(generate_clock(dut))  # Generate clock

    # Apply reset
    dut.resetq.value = 0
    await RisingEdge(dut.clk)

    # Check if all registers are zeroed out
    assert dut.pc.value == 0, f"Expected pc to be 0, got {dut.pc.value}"
    assert dut.dsp.value == 0, f"Expected dsp to be 0, got {dut.dsp.value}"
    assert dut.st0.value == 0, f"Expected st0 to be 0, got {dut.st0.value}"
    assert dut.rsp.value == 0, f"Expected rsp to be 0, got {dut.rsp.value}"

    # De-assert reset and check if the values change to next
    dut.pcN.value = 10
    dut.resetq.value = 1
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.pc.value == 10, f"Expected pc to be 10 after reset deassertion, got {dut.pc.value}"