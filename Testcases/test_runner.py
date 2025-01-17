import os
import argparse
from pathlib import Path
from cocotb.runner import get_runner


TEST_ROOT = Path(__file__).resolve().parent
SIM_BUILD_DIR = TEST_ROOT.joinpath("sim_build")
PROJECT_ROOT = TEST_ROOT.parent
J1_FILE = PROJECT_ROOT.joinpath("j1.v")
STACK_FILE = PROJECT_ROOT.joinpath("stack.v")
DEFAULT_TESTCASE_FILENAME = "test_j1"
DEFAUTL_HDL_TOPLEVEL = "j1"
DEFAULT_SOURCES = [J1_FILE, STACK_FILE]

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

def test_design_runner(module_name : str, hdl_toplevel : str, sources : list[str]):
    if SIM_BUILD_DIR.exists():
        delete_directory(SIM_BUILD_DIR)

    sim = os.getenv("SIM", "icarus")

    header_files = [PROJECT_ROOT]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        includes=header_files,
        waves=True
    )

    runner.test(hdl_toplevel=hdl_toplevel, test_dir=TEST_ROOT, test_module=module_name)

def print_run(module_name, withColor, hdl_toplevel, sources):
    if (withColor):
        print(f"{bcolors.HEADER}\n### STARTING TEST {module_name} #################{bcolors.ENDC}\n")
        test_design_runner(module_name, hdl_toplevel, sources)
        print(f"{bcolors.HEADER}\n### ENDING TEST {module_name} #################{bcolors.ENDC}\n")
    else:
        print(f"\n### STARTING TEST {module_name} #################\n")
        test_design_runner(module_name, hdl_toplevel, sources)
        print(f"\n### ENDING TEST {module_name} #################\n")

def delete_directory(path):
    path = Path(path)
    for item in path.iterdir():
        if item.is_dir():
            delete_directory(item)
        else:
            item.unlink()
    path.rmdir() 

if __name__ == "__main__":
    parser = argparse.ArgumentParser("J1 Chip Test Simulation", description="Starts a cocotb runner.")
    parser.add_argument("-F", "--testfile", help="The file containing the cocotb testcases.", action="store")
    parser.add_argument("-T", "--toplevel", help="The hdl toplevel definition.", action="store")
    parser.add_argument("-S", "--sources", help="The verilog sources needed. (Only filenames. Files are expected to be in the root directory.)", action="extend", nargs="*")
    parser.add_argument("-C", "--color", help="If the output should be colored.", action="store_true")
    args = parser.parse_args()
    
    testfile = lambda tf : DEFAULT_TESTCASE_FILENAME if tf is None else tf
    toplevel = lambda tl : DEFAUTL_HDL_TOPLEVEL if tl is None else tl
    sources = lambda s : DEFAULT_SOURCES if s is None else [PROJECT_ROOT.joinpath(x) for x in s]

    print("\nExecuting test runner with the following arguments:\n", testfile(args.testfile), "\n", args.color, "\n", toplevel(args.toplevel), "\n", sources(args.sources))

    print_run(testfile(args.testfile), args.color, toplevel(args.toplevel), sources(args.sources))
