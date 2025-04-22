`timescale 1ns / 10ps
import wb_pkg::*;               //why? I did not import the interfaces and it worked?
import i2c_pkg::*;
import i2cmb_env_pkg::*;
import ncsu_pkg::*;

module top();


parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;

logic [7:0] reg_read;

 
logic op;
bit [7:0] write_data[];
logic [7:0] read_data[];
logic transfer_complete;

//********************************************************
////////////INSTANTIATING INTERFACES AND CLASSES///////////
wb_agent WAgent;
i2c_agent I2CAgent;
i2cmb_environment I2CMBEnv;
i2cmb_generator Generator;
i2cmb_env_configuration Configuration;

wb_transaction WTransaction;
i2c_transaction I2CTransaction;

////////////BENCHES///////////////
i2cmb_test Test;
FSMR_permission_test FSM_test; 
I2C_sda_check i2c_sda_test;
test_base zero_base;
dpr_register_test dpr_test;
cmdr_status_bits cmdr_status_test;
cmdr_read_test cmdr_r_test;
invalid_address_test inv_add_test;
iicmb_core_enable_test core_test;
Command_after_command_test cmd_cmd_test;
Invalid_bus_range_test bus_range_test;
test_random random_test;
FSM_reset_test fsm_reset_test;
// ****************************************************************************


// Clock generator
initial begin: clk_gen 
 clk = 1'b0;
 forever begin
   #5 clk = ~clk;
   end
 end
 


// ****************************************************************************
// Reset generator
property scl_sda_inactive_during_reset;
  @(posedge clk)
  disable iff (!rst)
   ($isunknown(scl) && $isunknown(sda));
endproperty

initial begin: rst_gen
 assert property(scl_sda_inactive_during_reset);
 #113 rst = 1'b0;
 end




i2c_if #(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),.I2C_DATA_WIDTH(I2C_DATA_WIDTH)) i2c_bus(.SCL(scl),.SDA(sda));


wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i),
  //Interface           //test
  .irq_i(irq)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

/*
initial begin:Top
	Test = new("Test");
	Test.i2c_bus = i2c_bus;
	Test.wb_bus = wb_bus;
	Test.make_and_load();
	Test.build();

	Test.run();
	
	$finish;
	
end
*/

initial begin:All_test

  #150;

  
  core_test = new("iicmb_core_test");  //Always run this test first as it will set the enable bit in CSR register
	core_test.i2c_bus = i2c_bus;
	core_test.wb_bus = wb_bus;
	core_test.make_and_load();
	core_test.build();

	core_test.run();

  fsm_reset_test = new("fsm_rest_test"); 
	fsm_reset_test.i2c_bus = i2c_bus;
	fsm_reset_test.wb_bus = wb_bus;
	fsm_reset_test.make_and_load();
	fsm_reset_test.build();

	fsm_reset_test.run();

  //cmd_cmd_test = new("command_after_command_test");
	//cmd_cmd_test.i2c_bus = i2c_bus;
	//cmd_cmd_test.wb_bus = wb_bus;
	//cmd_cmd_test.make_and_load();
	//cmd_cmd_test.build();

	//cmd_cmd_test.run();

  /*
  bus_range_test = new("iicmb_core_test"); 
	bus_range_test.i2c_bus = i2c_bus;
	bus_range_test.wb_bus = wb_bus;
	bus_range_test.make_and_load();
	bus_range_test.build();

	bus_range_test.run();
  


	FSM_test = new("FSM_Test");
	FSM_test.i2c_bus = i2c_bus;
	FSM_test.wb_bus = wb_bus;
	FSM_test.make_and_load();
	FSM_test.build();

	FSM_test.run();

  i2c_sda_test = new("I2C_sda_check");
	i2c_sda_test.i2c_bus = i2c_bus;
	i2c_sda_test.wb_bus = wb_bus;
	i2c_sda_test.make_and_load();
	i2c_sda_test.build();

	i2c_sda_test.run();

  zero_base = new("I2C_sda_check");
	zero_base.i2c_bus = i2c_bus;
	zero_base.wb_bus = wb_bus;
	zero_base.make_and_load();
	zero_base.build();

	zero_base.run();

  dpr_test = new("dpr_test");
	dpr_test.i2c_bus = i2c_bus;
	dpr_test.wb_bus = wb_bus;
	dpr_test.make_and_load();
	dpr_test.build();

	dpr_test.run();


  cmdr_status_test = new("cmdr_status_test");
	cmdr_status_test.i2c_bus = i2c_bus;
	cmdr_status_test.wb_bus = wb_bus;
	cmdr_status_test.make_and_load();
	cmdr_status_test.build();

	cmdr_status_test.run();


  cmdr_r_test = new("cmdr_r_test");
	cmdr_r_test.i2c_bus = i2c_bus;
	cmdr_r_test.wb_bus = wb_bus;
	cmdr_r_test.make_and_load();
	cmdr_r_test.build();

	cmdr_r_test.run();
 

  inv_add_test = new("inv_add_test");
	inv_add_test.i2c_bus = i2c_bus;
	inv_add_test.wb_bus = wb_bus;
	inv_add_test.make_and_load();
	inv_add_test.build();

	inv_add_test.run();



  random_test = new("random_test"); 
	random_test.i2c_bus = i2c_bus;
	random_test.wb_bus = wb_bus;
	random_test.make_and_load();
	random_test.build();

	random_test.run();

  */


  //Test = new("Test");
	//Test.i2c_bus = i2c_bus;
	//Test.wb_bus = wb_bus;
	//Test.make_and_load();
	//Test.build();

	//Test.run();
  
	
	$finish;
	
end 
	
	
property i2c_clock_check;
	@(posedge clk)
  disable iff (rst)
  $rose(scl) |-> ##[1:10] $fell(scl);
	endproperty
	
property bus_taken_test;
	@(posedge clk)	1'b1;                                 //Always true
	endproperty 

	
//initial begin
	//assert property(scl_sda_inactive_during_reset);
//end

		   
//initial begin 
	//assert property(i2c_clock_check);
//end

//initial begin 
	//assert property(bus_taken_test);
//end

logic[7:0] temp_read_data_sig;
property csr_reset_test;    //property can not be defined inside a procedural block
		@(posedge clk) 
    disable iff (rst)
    temp_read_data_sig[7] == 1'b0;
	endproperty
initial begin:CSR_TEST
  #20;
  if(rst == 1'b1) begin
    //wb_bus.master_read(8'h00,temp_read_data_sig);
    //assert property(csr_reset_test);
  end
end

endmodule