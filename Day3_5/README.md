# RISC-V_MYTH_Workshop

For students of "Microprocessor for You in Thirty Hours" Workshop, offered by for VLSI System Design (VSD) and Redwood EDA, find here accompanying live info and links.

Refer to README at [stevehoover/RISC-V_MYTH_Workshop](https://github.com/stevehoover/RISC-V_MYTH_Workshop) for lab instructions.

Add your codes in the [calculator_solutions.tlv](calculator_solutions.tlv) and [risc-v_solutions.tlv](risc-v_solutions.tlv) files and **keep committing** to your repository after every lab.

|Lab referece|Sanbox Link|
|---|---|
Operations Mux 1:4| https://makerchip.com/sandbox/0PNf4hZrx/0vghEW0 | 
Fibonacci calc	| https://makerchip.com/sandbox/0PNf4hZrx/0qjh1O9 | 
Pipeline	| https://makerchip.com/sandbox/0PNf4hZrx/0wjhvLO# | 
Calc and counetr pipiline	| https://makerchip.com/sandbox/0PNf4hZrx/0xGhLJr |
simple calc and count	| https://makerchip.com/sandbox/0PNf4hZrx/0vghEW0# |
Validity	| https://makerchip.com/sandbox/0PNf4hZrx/0k5hkk5 |
Mem and recall	| https://myth3.makerchip.com/sandbox/02kfkh0Mk/0oYhDD6 |

## Day 3
### Hierarchy :
- used for reapeting a module  or library 
- " Lexical re-enrtance" -  used to jump between diferent context  

## Day 4 - Basic RISC-V microarchitecture
Basic elements:
- program counter - pointer into instruction memory , instructions that we need to next step 
- Instruction memory 
- Decoder - will interpret the instruction selected by PC ( with all elements intsr , register, immediate values) 
- Registers (source, destination) , must be ast least 2 port read register file (because we need min 2 source reg), 1 write register fiel
- ALU - performing the arithmetic 
- Data memory for data ( for store and load instructions )

Lab: https://raw.githubusercontent.com/stevehoover/RISC-V_MYTH_Workshop/ecba3769fff373ef6b8f66b3347e8940c859792d/tlv_lib/risc-v_shell_lib.tlv
![](4-1.png)
The starting code makerchip sandbox contains a std infrastructure for TLV with some macro definitions .  Some elements are "m4" - is a macro preprocesor use to define a asambler . So you can insert test programs. 
 ``` *passed = *cyc_cnt > 40; ``` and ```   *failed = 1'b0;``` sued to setup the numbers of clocks and a pass message
- there are some macros that are instantiating some elements (Instr mem, register file , data mem) :
  - //m4+imem(@1)    // Args: (read stage)  --  the asm code is loaded here 
  - //m4+rf(@1, @1)  // Args: (read stage, write stage) - if equal, no register bypass is required
  - //m4+dmem(@4)    // Args: (read/write stage)
Useful tips: 
- if mouse is hovered over the diagram elements it willl so the expressions
- in wave form diagram is a section with elements for visualization window 

### PC:
- Reset of the PC must be done based on previous "reset" of the previous instruction. if the previous instruction was a reset the current instruction should use 0, to include the first non reset instruction in the pipeline.
The incrementation must be done with 4 , because of the instructions are 32 bit so we need 4 memory locations.
- Fetch : we need to connect the IMem to the PC by ```$inem_rd_addr[M4_IMEN_INDEX_CNT-1:0]``` (wich is needs PC/4 values) , the data will come out from ```$inem_rd_data``` conencted to a Decoder input ```$instr[31:0]``` . The read from mem has also a n enable signal.
  based on memory size PC range must be define.
### Decode Logic :
Instr[1:0] are always zero  ![](4-2.png)
- Instruction type : To implement the set of instruction we use commands that check values with don't care values: ``` $is_i_instr = $ instr[6:2] ==? 5'b0000x || ...
![](4-3.png)
- Immediate value : it is 32 bita nd depends on the instruction type. This is formed by multiple 
Concatenation in TLV: ``{ {21{$instr[31]}}, $instr[30:20]}``` - final vector is formed by 21 copies of instr[31] bit + instr[30:20] . 
- The rest of instruction fields have fixed position independent of he type: 
![](4-4.png)
- Decode particular instructions for used instructions:
![](4-4.png) slide 13

### Register file and ALU:
It is a macro ready done, capable for 2-read and 1-write.
![](4-4.png) slide 21
- First we need to hook the read signals : ```rf_rd_enablex``` to ```rsx_valid``` , to enable the read and ```rsx``` fields to RF index ```rf_rd_index```. 
- connect the read values to ALU , implemented ```addi``` and ```add```, and connect the output of the ALU to RF write signals
- the read usually is done for values written a previous step . 
insert array details!!! and slide 22.

### Branches
- Compute when a branch (instructions "bxxx") is needed, and where to branch ( PC of the branch and the immediate value of the instr). 
The branch target PC value will update the PC when previous instrction is a branch instruction (signal ```$taken_br``` will triger this).  

Final test example:  ```*passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9);``` - testbench will monitor the value from ```/xreg[10]``` from RF . The name of the value from that register is ```$value```. ```>>5``` used to log more waveforms after the result is done , not to stop suddenly. When value will be equal with proper sum the simulation will stop.
  
## Day 5 - Pipelined RISC-V CPU
