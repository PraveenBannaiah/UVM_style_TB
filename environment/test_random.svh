import ncsu_pkg::*;

class test_random extends ncsu_component#(.T(ncsu_transaction));
	
	i2cmb_environment I2CMBEnv;
	i2cmb_generator Generator;
	i2cmb_env_configuration Configuration;
	
	i2c_transaction I2CTransaction;
	wb_transaction WTransaction;
	
	virtual i2c_if #(7,8) i2c_bus;
	virtual wb_if #(2,8) wb_bus;
	
	function new(string name = "", ncsu_component #(T) parent = null); 
		super.new(name,parent);
		
		Configuration = new("cfg");
		Generator = new("gen");
		I2CMBEnv = new("env");
		
    endfunction
	
	function void build();
	
		I2CMBEnv.set_configuration(Configuration);
		I2CMBEnv.set_configuration(Configuration);
		I2CMBEnv.i2c_bus = this.i2c_bus;
		I2CMBEnv.wb_bus = this.wb_bus;
		I2CMBEnv.build();
		
		Generator.set_agent(.I2C_agent(I2CMBEnv.get_I2C_agent()),.WB_agent(I2CMBEnv.get_WB_agent()));
	endfunction
	
	
	function void make_and_load();
		bit [7:0] temp_write = 8'h0;
		int index = 0;
		
		I2CTransaction = new();
		WTransaction = new();
		
		repeat(32) begin
			I2CTransaction = new();
			WTransaction = new();
            if(WTransaction.randomize())
                $display("\n Randomize successful");
            else 
                $display("\n Randomize unsuccessful");
            WTransaction.single_trans = 1'b1;
			//I2CTransaction.received_data = WTransaction.write_data;
			//I2CTransaction.op = WTransaction.op;
            //I2CTransaction.address = WTransaction.slave_address;
			Generator.wb_trans[index] = WTransaction;
			//Generator.i2c_trans[index] = I2CTransaction;
			temp_write = temp_write + 1;
			index = index + 1;
		end
		
		
		
		
	endfunction
	
	virtual task run();
		I2CMBEnv.run();
		Generator.run();
	endtask
	
endclass