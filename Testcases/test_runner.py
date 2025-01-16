import os
import argparse
from pathlib import Path
from cocotb.runner import get_runner


TEST_ROOT = Path(__file__).resolve().parent
PROJECT_ROOT = TEST_ROOT.parent
J1_FILE = PROJECT_ROOT.joinpath("j1.v")
STACK_FILE = PROJECT_ROOT.joinpath("stack.v")
DEFAULT_TESTCASE_FILENAME = "test_j1"

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def test_design_runner(module_name):
    sim = os.getenv("SIM", "icarus")

    sources = [J1_FILE, STACK_FILE]
    header_files = [PROJECT_ROOT]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="j1",
        includes=header_files,
        waves=True
    )

    runner.test(hdl_toplevel="j1", test_dir=TEST_ROOT, test_module=module_name)

def print_run(module_name, withColor):
    if (withColor):
        print(f"{bcolors.HEADER}\n### STARTING TEST #################{bcolors.ENDC}\n")
        test_design_runner(module_name)
        print(f"{bcolors.HEADER}\n### ENDING TEST #################{bcolors.ENDC}\n")
    else:
        print("\n### STARTING TEST #################\n")
        test_design_runner(module_name)
        print("\n### ENDING TEST #################\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser("J1 Chip Test Simulation", description="Starts a cocotb runner.")
    parser.add_argument("-T", "--testfile", help="The file containing the cocotb testcases.", action="store")
    parser.add_argument("-C", "--color", help="If the output should be colored.", action="store_true")
    args = parser.parse_args()
    
    if args.testfile is None:
        print_run(DEFAULT_TESTCASE_FILENAME, args.color)
    else:
        print_run(args.testfile, args.color)
