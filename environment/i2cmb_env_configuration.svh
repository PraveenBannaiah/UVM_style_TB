import ncsu_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;
class i2cmb_env_configuration extends ncsu_configuration;
	int NUM_I2C_BUSSES;
	int I2C_ADDR_WIDTH;
	int I2C_DATA_WIDTH;
	
	//Configuration class objects
	i2c_configuration I2CCfg;
	wb_configuration WBCfg;
	
	function new(string name=""); 
		super.new(name);
		I2CCfg = new("I2C_agent_config");
		WBCfg = new("WB_agent_config");
    endfunction
	
endclass