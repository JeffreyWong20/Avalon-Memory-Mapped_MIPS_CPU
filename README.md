# Avalon_Memory-Mapped_MIPS_CPU
>The overall goals are to develop a working synthesisable MIPS-compatible CPU. This CPU will interface with the world using a memory-mapped bus, which gives it access to memory and other peripherals.

##Directory

* ./Docs directory contains the information of the data_sheet and its soecification

* ./test directory is about the testing session of the CPU. It contains the testcases(both in assembly code, machine code), the mock memory unit(for the sake of testing the CPU) and the testbench.v file which was aimmed to connect the CPU with the memory unit.

* ./rtl directory is the register level design of the CPU. It contains the actually systemverilog source code of the CPU.


##Run
By calling the shell script within the test folder.




