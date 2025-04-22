class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

	virtual i2c_if #(7,8) i2c_bus;
	i2c_configuration configuration;
	ncsu_component #(T) agent;
	
	T I2C_monitor_trans;
	
	function new(string name = "", ncsu_component #(T) parent = null);
	  super.new(name,parent);  
	endfunction 
	
	function void set_configuration(i2c_configuration cfg);
      configuration = cfg;
    endfunction
	
	function void set_agent(ncsu_component#(T) agent);
      this.agent = agent;
    endfunction
	
	task run();
		bit flag;
		forever begin
			I2C_monitor_trans = new("I2C_monitored_trans");
			i2c_bus.monitor(.addr(I2C_monitor_trans.address),.op_type(I2C_monitor_trans.op),.data(I2C_monitor_trans.monitor_data),.flag(flag));
			if(flag == 1'b1) begin
				//$display("\n (I2C Monitor) ADDRESS:%d    DATA:%d   OP:%d",I2C_monitor_trans.address,I2C_monitor_trans.monitor_data, I2C_monitor_trans.op);
				agent.nb_put(I2C_monitor_trans);
			end
		end
	
	endtask
	
endclass