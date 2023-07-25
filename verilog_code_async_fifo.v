module async_fifo(wr_clk_i, rd_clk_i, rst_i,
wdata_i, wr_en_i, full_o, not_writing, rdata_o, rd_en_i, empty_o, not_reading);
   
   parameter WIDTH = 22; //defining parameters so we have flexiblity in adjusting the size of FIFO.
   parameter DEPTH = 8192;
   parameter PTR_WIDTH = $clog2(DEPTH); 
   
   //input output ports
   input wr_clk_i          // write clock --input
    , rd_clk_i             //read clock--input
    , rst_i                // reset for setting all register to 0--input
    , wr_en_i              // enable for writing data --input
    , rd_en_i;             // enable for reading data --input
   input [WIDTH-1:0] wdata_i; // input data register
   output reg full_o, empty_o; //flags for full and conditions.
   output reg  not_writing, not_reading; // indicates whether writing and reading operation is active or not.
   output reg [WIDTH-1:0] rdata_o; // output data register
   
   //internal signal 
   reg [PTR_WIDTH-1:0] wr_ptr, rd_ptr;           // binary pointer register
   reg [PTR_WIDTH-1:0] wr_ptr_gray, rd_ptr_gray; // gray pointer register
   reg [PTR_WIDTH-1:0] wr_ptr_gray_rd_clk, rd_ptr_gray_wr_clk; // gray pointer for synchronisation with oppposite clocks.
   reg wr_t_f, rd_t_f; // registers for generating full and empty condition with synchronisation
   reg wr_t_f_rd_clk, rd_t_f_wr_clk; //registers for generating full and empty condition with synchronisation
   integer i;

   //storage declarartion
   reg[WIDTH-1:0] mem [DEPTH-1:0];

  
   //  for FIFO write operations
   always@(posedge wr_clk_i) begin
   case({rst_i})
      1'b1: begin
	     //reset the all reg variable to 0 value
         full_o = 0;
	     not_writing = 0;
	     not_reading = 0;
	     empty_o = 1;
	     rdata_o = 0;
	     wr_ptr = 0;
	     rd_ptr = 0;
	     wr_ptr_gray = 0;
	     rd_ptr_gray = 0;
		 wr_ptr_gray_rd_clk = 0;
		 rd_ptr_gray_wr_clk = 0;
	     wr_t_f = 0;
	     rd_t_f = 0;
	     for(i = 0; i<DEPTH; i =i+1) mem[i] =0;
	    
	  end
	  1'b0:begin
	  if(wr_en_i==1) begin
	  if(wr_ptr==DEPTH-1) begin
	  wr_ptr = 0;
      wr_t_f = ~wr_t_f;
	  end
	  else begin 
	  wr_ptr = wr_ptr+1;
	  mem[wr_ptr] = wdata_i;
	  end
	  assign wr_ptr_gray = wr_ptr^(wr_ptr>>>1);
	  end
	  else begin
	  not_writing = 1;
	  end
	  end
      endcase
      end

   // for FIFO read operations
   always@(posedge rd_clk_i) begin
   
	if(rd_en_i==1) begin
    if(rd_ptr==DEPTH-1) begin
    rd_ptr = 0;
    rd_t_f = ~rd_t_f;
	end
	else begin
	rd_ptr = rd_ptr+1;
	rdata_o = mem[rd_ptr];
	end
	assign rd_ptr_gray = rd_ptr^(rd_ptr>>>1); // gray to binary conversion 	    
    end
    else begin
    not_reading = 1; 
    end
    end
	//synchronizer for synchronize the write and read clock using gray pointer
   always@(posedge wr_clk_i) begin
   rd_ptr_gray_wr_clk = rd_ptr_gray;
   rd_t_f_wr_clk = rd_t_f;end
    always@(posedge rd_clk_i) begin
   wr_ptr_gray_rd_clk = wr_ptr_gray;
   wr_t_f_rd_clk = wr_t_f;
   end
   // full and empty condition generation using gray pointers
   always@(*)  begin
   full_o = 0;
   empty_o = 0;
   if(wr_ptr_gray == rd_ptr_gray_wr_clk && wr_t_f != rd_t_f_wr_clk) begin
   full_o = 1;
   end
   if(wr_ptr_gray_rd_clk == rd_ptr_gray && wr_t_f_rd_clk == rd_t_f) begin
   empty_o = 1;
   end
   end endmodule
