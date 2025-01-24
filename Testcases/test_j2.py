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
        dut.clock.value = 0
        await Timer(1, units="sec")
        dut.clock.value = 1
        await Timer(1)

# @cocotb.test()
# async def testcase_template(dut):
#     """Test DESCRIPTION"""
#     await cocotb.start(generate_clock(dut))  # Generate clock

#     # Initalize TESTCASE
#     dut.active_low_reset.value = 0
#     await RisingEdge(dut.clock)
#     await FallingEdge(dut.clock)

#     # Check SOMETHING
#     assert dut.active_low_reset.value == 0, f"Expected TESTVAR to be 0, got {dut.active_low_reset.value}"
#     dut._log.info("my_signal_1 is %s", dut.active_low_reset.value)

@cocotb.test()
async def testcase_alu_basic(dut):
    """Test basic ALU T & N Operation"""
    await cocotb.start(generate_clock(dut))  # Generate clock

    dut.instruction.value = INSN["TOP"]
    dut.data_stack_top.value = 5
    await RisingEdge(dut.clock)  # Trigger Operation
    await FallingEdge(dut.clock)  # Any Await would work -> data_stack_top = st0N wird NACH RisingEdge zugewiesen
    assert dut.data_stack_top.value == 5, f"Expected data_stack_top to still be 5 aftere T, got {dut.data_stack_top.value}"

    dut.instruction.value = INSN["SEC"]
    dut.data_stack_second.value = 10
    await RisingEdge(dut.clock) 
    await FallingEdge(dut.clock)  
    assert dut.data_stack_top.value == 10, f"Expected data_stack_top to be 10 after N, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_add(dut):
    """Test ADD ALU Operation"""
    await cocotb.start(generate_clock(dut))

    dut.instruction.value = INSN["ADD"]
    dut.data_stack_top.value = 5
    dut.data_stack_second.value = 3
    await RisingEdge(dut.clock) 
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 8, f"Expected data_stack_top to be 8 after ADD, got {dut.data_stack_top.value}"


@cocotb.test()
async def testcase_alu_and(dut):
    """Test AND ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["AND"]
    dut.data_stack_top.value = 0b1101
    dut.data_stack_second.value = 0b1011
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 0b1001, f"Expected data_stack_top to be 0b1001 after AND, got {dut.data_stack_top.value}"


@cocotb.test()
async def testcase_alu_or(dut):
    """Test OR ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["OR"]
    dut.data_stack_top.value = 0b1101
    dut.data_stack_second.value = 0b1011
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 0b1111, f"Expected data_stack_top to be 0b1111 after OR, got {dut.data_stack_top.value}"


@cocotb.test()
async def testcase_alu_xor(dut):
    """Test XOR ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["XOR"]
    dut.data_stack_top.value = 0b1101
    dut.data_stack_second.value = 0b1011
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 0b0110, f"Expected data_stack_top to be 0b0110 after XOR, got {dut.data_stack_top.value}"


@cocotb.test()
async def testcase_alu_invert(dut):
    """Test Invert ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["INVERT"]
    dut.data_stack_top.value = 0b1101
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    # Size of data_stack_top has to be acounted for
    assert dut.data_stack_top.value == 0b11111111111111111111111111110010, f"Expected data_stack_top to be 11111111111111111111111111110010 after Invert, got {dut.data_stack_top.value}"


@cocotb.test()
async def testcase_alu_equal(dut):
    """Test equal ALU Operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["EQUAL"]
    dut.data_stack_top.value = 5
    dut.data_stack_second.value = 5
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value != 0, f"Expected data_stack_top to not be 0 after equal, got {dut.data_stack_top.value}"


@cocotb.test()
async def testcase_alu_smaller_signed(dut):
    """Test smaller signed ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.instruction.value = INSN["SMALLER_SIGNED"]
    dut.data_stack_top.value = 5
    dut.data_stack_second.value = -5
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value != 0, f"Expected data_stack_top to not be 0 after smaller signed, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_shift(dut):
    """Test rshift & lshift ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.instruction.value = INSN["RSHIFT"]
    dut.data_stack_top.value = 1
    dut.data_stack_second.value = 2
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 1, f"Expected data_stack_top to be 1 after rshift, got {dut.data_stack_top.value}"

    dut.instruction.value = INSN["LSHIFT"]
    dut.data_stack_top.value = 1
    dut.data_stack_second.value = 2
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 4, f"Expected data_stack_top to be 4 after lshift, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_return(dut):
    """Test return ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    # Fill return stack
    dut.return_stack_write_enable.value = 1
    dut.return_stack_pointer_top.value = 0
    dut.instruction.value = 0b0110000000100100
    dut.data_stack_top.value = 73
    await RisingEdge(dut.clock)

    # Set data_stack_top to something else
    dut.return_stack_write_enable.value = 0
    dut.instruction.value = INSN["TOP"]
    dut.data_stack_top.value = 100
    await RisingEdge(dut.clock)

    # Check return stack
    dut.instruction.value = INSN["RETURN"]
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 73, f"Expected data_stack_top to be 73 after return, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_mem_din(dut):
    """Test memory din ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.instruction.value = INSN["MEM_DIN"]
    dut.memory_data_in.value = 9
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 9, f"Expected data_stack_top to be 9 after memory data in, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_io_din(dut):
    """Test io din ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.instruction.value = INSN["IO_DIN"]
    dut.io_data_in.value = 66
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 66, f"Expected data_stack_top to be 66 after i/o data in, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_depth(dut):
    """Test depth ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.data_stack_write_enable.value = 1
    dut.data_stack_pointer_top.value = 0
    dut.data_stack_top.value = 49
    dut.instruction.value = 0b0110000000010001

    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)

    dut.data_stack_write_enable.value = 0
    dut.return_stack_write_enable.value = 1
    dut.return_stack_pointer_top.value = 0
    dut.instruction.value = 0b0110000000100100

    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)

    dut.instruction.value = INSN["DEPTH"]
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 35, f"Expected data_stack_top to be 35 after depth, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_alu_smaller(dut):
    """Test smaller ALU Operation"""
    await cocotb.start(generate_clock(dut))  

    dut.instruction.value = INSN["SMALLER"]
    dut.data_stack_top.value = 5
    dut.data_stack_second.value = 5
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.data_stack_top.value == 0, f"Expected data_stack_top to be 0 after smaller, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_jump(dut):
    """Test jump operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["JUMP"]
    dut.data_stack_top.value = 0
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.program_counter.value == 16, f"Expected program_counter to jump to 16, got {dut.program_counter.value}"

@cocotb.test()
async def testcase_call(dut):
    """Test call operation"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["CALL"]
    dut.data_stack_top.value = 0
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.program_counter.value == 32, f"Expected program_counter to call to 32, got {dut.program_counter.value}"

@cocotb.test()
async def testcase_cond_jump(dut):
    """Test conditional jump"""
    await cocotb.start(generate_clock(dut)) 

    dut.instruction.value = INSN["COND_JUMP"]
    dut.data_stack_second.value = 0
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.program_counter.value == 64, f"Expected program_counter to jump to 64, got {dut.program_counter.value}"

@cocotb.test()
async def testcase_no_insn(dut):
    """Test no valid instruction"""
    await cocotb.start(generate_clock(dut))  

    dut.instruction.value = INSN["NO_INSN"]
    dut.data_stack_write_enable.value = 0
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    xes = ("x" * 32)
    assert dut.data_stack_top.value == xes, f"Expected data_stack_top to be x after invalid instruction, got {dut.data_stack_top.value}"

@cocotb.test()
async def testcase_data_stack(dut):
    """Test Data Stack"""
    await cocotb.start(generate_clock(dut))

    dut.data_stack_pointer_top.value = 0
    dut.data_stack_top.value = 49
    dut.instruction.value = 0b0110000000010001

    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)

    assert dut.data_stack_pointer_top.value == 3, f"Expected data_stack_pointer_top to be 3, got {dut.data_stack_pointer_top.value}"
    assert dut.data_stack_second.value == 49, f"Expected data_stack_second to be 49, got {dut.data_stack_second.value}"

@cocotb.test()
async def testcase_return_stack(dut):
    """Test Return Stack"""
    await cocotb.start(generate_clock(dut))

    dut.return_stack_pointer_top.value = 0
    dut.instruction.value = 0b0110000000100100

    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)

    assert dut.return_stack_pointer_top.value == 2, f"Expected return_stack_pointer_top to be 2, got {dut.active_low_reset.value}"

@cocotb.test()
async def testcase_mem_write(dut):
    """Test Memory Write"""
    await cocotb.start(generate_clock(dut))

    dut.instruction.value = INSN["ADD_TO_MEM"]
    dut.data_stack_top.value = 10
    dut.data_stack_second.value = 30

    await RisingEdge(dut.clock)

    assert dut.data_stack_second.value == 30, f"Expected data_stack_top to be 40 got {dut.data_stack_top.value}"
    assert dut.data_out.value == 30, f"Expected data_out to be 40 got {dut.data_out.value}"
    assert dut.memory_write_enable.value != 0, f"Expected memory_write_enable not be 0 got {dut.memory_write_enable.value}"
    assert dut.memory_address.value == 40, f"Expected data_out to be memory_address to be 130 got {dut.memory_address.value}"

@cocotb.test()
async def testcase_io_write(dut):
    """Test IO Write"""
    await cocotb.start(generate_clock(dut))

    dut.instruction.value = INSN["ADD_TO_IO"]
    dut.data_stack_top.value = 20
    dut.data_stack_second.value = 60

    await RisingEdge(dut.clock)

    assert dut.data_out.value == 60, f"Expected data_out to be 60, got {dut.data_out.value}"
    assert dut.io_write_enable.value != 0, f"Expected io_write_enable not be 0 , got {dut.memory_write_enable.value}"
    assert dut.memory_address.value == 80, f"Expected memory_address to be 140, got {dut.memory_address.value}"

@cocotb.test()
async def test_reset(dut):
    """Test Reset"""
    await cocotb.start(generate_clock(dut))  # Generate clock

    # Apply reset
    dut.active_low_reset.value = 0
    await RisingEdge(dut.clock)

    # Check if all registers are zeroed out
    assert dut.program_counter.value == 0, f"Expected program_counter to be 0, got {dut.program_counter.value}"
    assert dut.data_stack_pointer_top.value == 0, f"Expected data_stack_pointer_top to be 0, got {dut.data_stack_pointer_top.value}"
    assert dut.data_stack_top.value == 0, f"Expected data_stack_top to be 0, got {dut.data_stack_top.value}"
    assert dut.return_stack_pointer_top.value == 0, f"Expected return_stack_pointer_top to be 0, got {dut.return_stack_pointer_top.value}"

    # De-assert reset and check if the values change to next
    dut.program_counter_next.value = 10
    dut.active_low_reset.value = 1
    await RisingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.program_counter.value == 10, f"Expected program_counter to be 10 after reset deassertion, got {dut.program_counter.value}"