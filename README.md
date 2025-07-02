# j2: A J1-Inspired CPU Implementation

This project is a hardware implementation of a stack-based CPU inspired by the J1 Forth CPU. The design is written in Verilog and includes simulation and test infrastructure.

## Features
- **Stack-based architecture**: Separate data and return stacks for efficient Forth-style computation.
- **Minimalist design**: Focused on simplicity and clarity, suitable for educational purposes and experimentation.
- **Custom instruction set**: Inspired by the J1 CPU, supporting Forth-like operations.
- **Simulation support**: Python-based test runner and test cases for functional verification.
- **Modular components**: Includes ALU, RAM, stack, and clock modules.

## Directory Structure
- `j2.v` / `j2_vivado_top.v`: Top-level Verilog modules for the CPU.
- `alu.v`: Arithmetic Logic Unit implementation.
- `memory_ram.v`: RAM module for data storage.
- `stack.v`: Stack implementation for data and return stacks.
- `sim_clock.v`: Simulation clock module.
- `common.h`: Common definitions and parameters.
- `constraint.sdc`: Timing constraints for synthesis.
- `Testcases/`: Python scripts for simulation and testing.
    - `test_j2.py`: Test cases for the CPU.
    - `test_runner.py`: Test runner script.

## Getting Started
1. **Simulation**: Use the Python scripts in `Testcases/` to run simulations and verify functionality.
2. **Synthesis**: Use the provided Verilog files and constraints for synthesis in FPGA tools (e.g., Vivado).
3. **Customization**: Modify or extend the instruction set and modules as needed for your application.

## References
- [J1 Forth CPU](https://excamera.com/sphinx/article-j1.html)
- [Forth Programming Language](https://forth-standard.org/)

