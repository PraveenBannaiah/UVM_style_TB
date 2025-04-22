import ncsu_pkg::*;
import wb_pkg::*;

class wb_agent extends ncsu_component#(.T(wb_transaction));
	
	ncsu_component#(T) subscribers[$];
	virtual wb_if #(2,8) wb_bus;

	wb_driver driver;
	wb_monitor monitor;
	
	wb_configuration configuration;
	//Class Instantiation 
	
	function new(string name = "", ncsu_component #(ncsu_transaction) parent = null); 
		super.new(name,parent);
	endfunction
	
	function void set_configuration(wb_configuration cfg);
		configuration = cfg;
	endfunction
	
	virtual function void nb_put(T trans);                                         //virtual keyword is important;
		foreach (subscribers[i]) subscribers[i].nb_put(trans);
	endfunction
	
	virtual task bl_put(T trans);
      driver.bl_put(trans);
    endtask


	virtual function void build();
		driver = new("driver",this);
		driver.wb_bus = this.wb_bus;
		driver.set_configuration(configuration);
		
		
		monitor = new("monitor",this);
		monitor.wb_bus = this.wb_bus;
		monitor.set_configuration(configuration);
		monitor.set_agent(this);

	endfunction
	
    virtual task run();
      fork monitor.run(); join_none
    endtask
	
	virtual function void connect_subscriber(ncsu_component#(T) subscriber);
		subscribers.push_back(subscriber);
	endfunction

endclass