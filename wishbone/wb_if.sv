interface wb_if       #(
      int ADDR_WIDTH = 32,                                
      int DATA_WIDTH = 16                                
      )
(
  // System sigals
  input wire clk_i,
  input wire rst_i,
  input wire irq_i,
  // Master signals
  output reg cyc_o,
  output reg stb_o,
  input wire ack_i,
  output reg [ADDR_WIDTH-1:0] adr_o,
  output reg we_o,
  // Slave signals
  input wire cyc_i,
  input wire stb_i,
  output reg ack_o,
  input wire [ADDR_WIDTH-1:0] adr_i,
  input wire we_i,
  // Shred signals
  output reg [DATA_WIDTH-1:0] dat_o,
  input wire [DATA_WIDTH-1:0] dat_i
  );

  initial reset_bus();

// ****************************************************************************              
   task wait_for_reset();
       if (rst_i !== 0) @(negedge rst_i);
   endtask

// ****************************************************************************              
   task wait_for_num_clocks(int num_clocks);
       repeat (num_clocks) @(posedge clk_i);
   endtask

// ****************************************************************************              
   task wait_for_interrupt();
       @(posedge irq_i);
   endtask

// ****************************************************************************              
   task reset_bus();
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        we_o <= 1'b0;
        adr_o <= 'b0;
        dat_o <= 'b0;
   endtask

// ****************************************************************************              
  task master_write(
                   input bit [ADDR_WIDTH-1:0]  addr,
                   input bit [DATA_WIDTH-1:0]  data
                   );  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= data;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b1;
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        @(posedge clk_i);

endtask        

// **************************************************************************** 
bit [7:0] read_FSM;
  bit read_fsm_flag = 1'b0;
bit disable_test = 1'b0;

property bus_taken_test;
@(posedge read_fsm_flag) disable iff(disable_test)
(read_FSM[7:4] != 4'b0);
endproperty

// property(bus_taken_test);


task master_read(
                 input bit [ADDR_WIDTH-1:0]  addr,
                 output bit [DATA_WIDTH-1:0] data
                 );                                                  
         read_fsm_flag = 1'b0;
        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= 'bx;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b0;
        @(posedge clk_i);
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        data = dat_i;
        if(addr == 8'h03) begin
            read_FSM = dat_i;
            read_fsm_flag = 1'b1;
        end

endtask        

// ****************************************************************************              
     task master_monitor(
                   output bit [ADDR_WIDTH-1:0] addr,
                   output bit [DATA_WIDTH-1:0] data,
                   output bit we                    
                  );
                         
          while (!cyc_o) @(posedge clk_i);                                                  
          while (!ack_i) @(posedge clk_i);
          addr = adr_o;
          we = we_o;
          if (we_o) begin
            data = dat_o;
          end else begin
            data = dat_i;
          end
          while (cyc_o) @(posedge clk_i);                                                  
     endtask 

endinterface
