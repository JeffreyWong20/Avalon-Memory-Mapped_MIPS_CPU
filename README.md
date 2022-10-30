# Avalon_Memory-Mapped_MIPS_CPU
The overall goals are to develop a synthesisable MIPS-compatible CPU. This CPU will interface with the world using a memory-mapped bus, which gives it access to memory and other peripherals.
>
> Developing a piece of IP which could be sold and distributed to many clients, allowing clients to integrate the CPU into any number of products. As a consequence the emphasis is on producing a production quality CPU with a robust testing process - Expect to work on any FPGA or ASIC
> 
> The emphasis on creating a "real" CPU makes this a more complex task. In particular, the emphasis on memory-based input/output is very realistic. The project is methodical and analytical in the way develop both CPU and its test-bench and test-cases.

## Project file structure

  
1. `./rtl`   : Contains the actually systemverilog source code of the CPU. (Register level design of the CPU)
    * `rtl/mips_cpu_bus.v` : An implementation of a MIPS CPU which meets the pre-specified template for signal names and interface timings.
    * `rtl/mips_cpu/*` :  Verilog modules ( Control Path, Data Path, ALU, State Machine ...)
2. `./test`  : Contains the testcases(both in assembly code, machine code), the mock memory unit(for the sake of testing the CPU) and the testbench.v file               which was aimmed to connect the CPU with the memory unit.
    * `./test/test_mips_cpu_bus.sh` : A test-bench for any CPU meeting the given interface. This will act as a test-bench for the CPU. 

3. `./Docs`  : Contains the information of the data_sheet and its soecification
    - `docs/mips_data_sheet.pdf` : A data-sheet for the CPU, data-sheet cover:

      - The overall architecture of the CPU.
      - At least one diagram of the CPU's architecture.
      - Design decisions taken when implementing the CPU.
      - The approach taken to testing CPUs.
      - Detailed diagram and flow-chart describing the testing flow and approach.
      - Area and timing summary for the "Cyclone IV E ‘Auto’" variant in Quartus (same as used in the EE1 "CPU" project).


## For Use
Run `./test/test_mips_cpu_bus.sh` to process a quick test (200 instructions) on the CPU.




