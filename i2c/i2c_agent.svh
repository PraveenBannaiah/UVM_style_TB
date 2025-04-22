import ncsu_pkg::*;
import i2c_pkg::*;

class i2c_agent extends ncsu_component#(.T(i2c_transaction));
	
	ncsu_component#(T) subscribers[$];
	
	virtual i2c_if #(7,8) i2c_bus;

	i2c_driver driver;
	i2c_monitor monitor;
	i2c_configuration configuration;
	
	
	//Class Instantiation 
	
	function new(string name = "", ncsu_component #(ncsu_transaction) parent = null); 
		super.new(name,parent);
	endfunction
	
	virtual function void nb_put(T trans);
		foreach (subscribers[i]) subscribers[i].nb_put(trans);
	endfunction
	
    function void set_configuration(i2c_configuration cfg);
		configuration = cfg;
	endfunction
	
	virtual task bl_put(T trans);
		driver.bl_put(trans);
    endtask
	
	virtual function void build();
		driver = new("driver",this);
		driver.set_configuration(configuration);
		driver.i2c_bus = this.i2c_bus;
		
		monitor = new("monitor",this);
		monitor.set_configuration(configuration);
		monitor.i2c_bus = this.i2c_bus;
		monitor.set_agent(this);
	endfunction
	
	virtual task run();
		fork monitor.run(); join_none
	endtask
	
	function void connect_subscriber(ncsu_component#(T) subscriber);
		subscribers.push_back(subscriber);
	endfunction
	
	
endclass