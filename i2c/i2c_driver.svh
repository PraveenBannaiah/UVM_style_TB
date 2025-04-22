import ncsu_pkg::*;
import i2c_pkg::*;
class i2c_driver extends ncsu_component#(.T(i2c_transaction));

	virtual i2c_if #(7,8) i2c_bus;               //Apparently we cant use .DATA_WIDTH(8) for interfaces for some reason
	T trans;
	i2c_configuration configuration;
	
	function new(string name = "", ncsu_component #(T) parent = null);
	  super.new(name,parent);                                         
	endfunction 
	
	function void set_configuration(i2c_configuration cfg);
		configuration = cfg;
    endfunction
	
	virtual task bl_put(T trans);
		i2c_bus.wait_for_i2c_transfer (.op(trans.op), .write_data(trans.received_data));
	endtask
	
endclass