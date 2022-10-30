# Avalon_Memory-Mapped_MIPS_CPU
> The overall goals are to develop a synthesisable MIPS-compatible CPU. This CPU will interface with the world using a memory-mapped bus, which gives it access to memory and other peripherals.
>
> Developing a piece of IP which could be sold and distributed to many clients, allowing clients to integrate the CPU into any number of products. As a consequence the emphasis is on producing a production quality CPU with a robust testing process - Expect to work on any FPGA or ASIC
> 
> The emphasis on creating a "real" CPU makes this a more complex task. In particular, the emphasis on memory-based input/output is very realistic. The project is methodical and analytical in the way develop both CPU and its test-bench and test-cases.

## Project file structure

* `./Docs`  : Contains the information of the data_sheet and its soecification
* `./test`  : Contains the testcases(both in assembly code, machine code), the mock memory unit(for the sake of testing the CPU) and the testbench.v file               which was aimmed to connect the CPU with the memory unit.
* `./rtl`   : Contains the actually systemverilog source code of the CPU. (Register level design of the CPU)


## For Use
Run `./test/test_mips_cpu_bus.sh` to process a quick test (200 instructions) on the CPU.




