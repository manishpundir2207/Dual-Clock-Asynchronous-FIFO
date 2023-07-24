Asynchronous FIFOs are used as buffers between two asynchronous clock domains to exchange data safely. Data
is written into the FIFO from one clock domain and it is read from another clock domain. This requires a memory
architecture wherein two ports of memory are available- one is for input (or write or push) operation and another
is for output (or read or pop) operation. Generally FIFOs are used where write operation is faster than read operation. However, even with the different speed and access types the average rate of data transfer remains constant.
FIFO pointers keep track of number of FIFO memory locations read and written and corresponding control logic
circuit prevents FIFO from either under flowing or overflowing. FIFO architectures inherently have a challenge of
synchronizing itself with the pointer logic of other clock domain and control the read and write operation of FIFO
memory locations safely. A detailed and careful analysis of synchronizer circuit along with pointer logic is required
to understand the synchronization of two FIFO pointer logic circuits which is responsible for accessing the FIFO
read and write ports independently controlled by different clocks.
