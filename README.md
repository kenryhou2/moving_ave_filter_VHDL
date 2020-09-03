# Moving_Ave_Filter_VHDL
- Self-paced project for Raytheon Digital Hardware Internship 
- Source code involving an entity of a 128 pt. moving average filter from an inferred circular register based FIFO along with .
- Testbench featuring interface with text files, and 
- Additional features include full, empty, almost full, almost empty flags.
- Moving average filter interfaces text files as IO streams. (Input_stream.txt, output_stream.txt)
- Features working with hardware loops, synchronized signals, bitwise division and addition.

Tested build environment:
```Windows 10 64-bits #ModelSim 10.5b```

# Software
- VHDL Hardware Language (Synthesizable and non-synthesizeable code)
- ModelSim

# Project Breakdown
Source code: moving_ave_filter_2.vhd
Initializes Entity: Moving_ave_filter
- 128 points deep, 8 bits wide (1 byte).
- almost empty count: 2, almost full count: 126
- Important Signals: 
- i_clock (200 MHz)
- i_wr_en and i_rd_en (write and read enables for FIFO)
- o_full_flag, o_empty_flag, o_almost_full_flag, o_almost_empty_flag
- r_DATA_CNT (register to hold amount of items in FIFO)
- r_FIFO_DATA (register array to hold data of FIFO)
- r_wr_ptr, r_rd_ptr
- o_div (output of the filter)

P_CONTROL Process: 
On the rising edge of the 200 MHz clk, the system will:
1. Check for reset
2. Check for read or write enables and upon clk count, update the count for r_DATA_CNT. 
    - If read enable only, decrement. If write enable only, increment. (WRITING TO the FIFO, READING FROM the FIFO)
3. Update read and write pointers to increment or decrement in a circular fashion.
4. If write enable is on, take the input data and write to the write pointer location in the FIFO

P_SUMMER Process:
1. Initialize temporary sum and previous sum registers to 0.
2. For each item in the FIFO, sum and divide by size of the FIFO (128) by right shifting (log128/log2) = 7 times.
3. Update temporary and previous sum registers
4. Output the division answer to o_div.

Combinational Code: (Following operations performed in parallel to the processes)
- Output o_rd_data from the location of the rd pointer.
- Boolean settings for the full, almost full, empty, and almost empty flags dependent on the size of r_DATA_CNT.

Testbench: moving_ave_filter_2_tb.vhd 
Output signal o_div is the signal outputting to output_stream.txt
There is a 2 clk lag between the input and output stream values.

# Potential Bugs and Improvement
- I noticed an immediate bug as I was simulating: the full FIFO wasn't being used. In fact the 0th index was never filled with values in the FIFO. Therefore, the indexing pointers were initialized incorrectly to start at the 1st index instead of the 0th.
This can be easily fixed by changing the indexing and initialization of the read and write registers/pointers.
- Finally, this moving average filter implementation is highly inefficient. In fact, the repetitive hardware looping for the summation can be completely replaced with three math operations detailed in the following diagram.
y[i] = y[i-1] + x[i+p] - x[i-q] where p = (M-1)/2 and q = p-1. And M being the size of the filter.

The significance of this equation is that the current moving average is the same as the moving average in the previous timestep added with the input of this timestep and substracted by the input of the previous timestep.
This means the 128 size FIFO summing loop can be replaced with a single register, reducing the code complexity, and memory size.
Note the purpose of this assignment is to train my proficiency with VHDL and not making an efficient moving average filter. There are plenty more ways to implement one.



# Useful Links
- [VHDL for moving average (My code wasn't this implementation)](https://surf-vhdl.com/how-to-implement-moving-average-in-vhdl/#:~:text=This%20VHDL%20implementation%20of%20moving,perform%20the%20output%20right%20shift.)
- [Register Basaed FIFO](https://www.nandland.com/vhdl/modules/module-fifo-regs-with-flags.html)
- [File IO in VHDL](https://www.nandland.com/vhdl/examples/example-file-io.html)
- [ModelSim Tutorial] (https://www.nandland.com/vhdl/tutorials/tutorial-modelsim-simulation-walkthrough.html)
- [Other VHDL Tutorial] (https://www.nandland.com/vhdl/tutorials/index.html)
