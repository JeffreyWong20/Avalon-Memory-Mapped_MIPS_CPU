# Avalon_Memory-Mapped_MIPS_CPU
>The overall goals are to develop a working synthesisable MIPS-compatible CPU. This CPU will interface with the world using a memory-mapped bus, which gives it access to memory and other peripherals.

## Project file structure

* `./Docs`  : Contains the information of the data_sheet and its soecification
* `./test`  : Contains the testcases(both in assembly code, machine code), the mock memory unit(for the sake of testing the CPU) and the testbench.v file               which was aimmed to connect the CPU with the memory unit.
* `./rtl`   : Contains the actually systemverilog source code of the CPU. (Register level design of the CPU)


## For Use
Run `./test/test_mips_cpu_bus.sh` to process a quick test (200 instructions) on the CPU.




