class wb_monitor extends ncsu_component#(.T(wb_transaction));

	virtual wb_if #(2,8) wb_bus;
	T monitor_trans;
	wb_configuration configuration;
	
	ncsu_component #(T) agent;
	
	function new(string name = "", ncsu_component #(T) parent = null); 
      super.new(name,parent);
    endfunction
	
	function void set_configuration(wb_configuration cfg);
      configuration = cfg;
    endfunction
	
	function void set_agent(ncsu_component#(T) agent);
      this.agent = agent;
    endfunction
	
	virtual task run();
		wb_bus.wait_for_reset();
		forever begin
			monitor_trans = new();
			wb_bus.master_monitor(.addr(monitor_trans.slave_address),.data(monitor_trans.monitor_data),.we(monitor_trans.we));
			//$display("\n(Wishbone Monitor) addr: %d, data:%d, we:%d",monitor_trans.slave_address,monitor_trans.monitor_data,monitor_trans.we);
			agent.nb_put(monitor_trans);
			end
	endtask
	
endclass