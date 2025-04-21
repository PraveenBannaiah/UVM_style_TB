import i2c_pkg::*;
import wb_pkg::*;
import ncsu_pkg::*;
import i2cmb_env_pkg::*;

class i2cmb_environment extends ncsu_component#(.T(ncsu_transaction));
	
	//Interfaces
	virtual i2c_if #(7,8) i2c_bus;
	virtual wb_if #(2,8) wb_bus;

	//Instantiating Agents, coverage, predictor and scoreboard components
	wb_agent WAgent;
	i2c_agent I2CAgent;

	i2cmb_coverage I2CMBCov;
	i2cmb_predictor I2CMBPred;
	i2cmb_scoreboard I2CMBScore;
	i2cmb_env_configuration configuration;
	
	
	function new(string name = "", ncsu_component #() parent=null);
		super.new(name,parent);
	endfunction
	
	virtual function void build();
		WAgent = new("WB_agent",this);
		WAgent.set_configuration(configuration.WBCfg);
		WAgent.wb_bus = this.wb_bus;
		WAgent.build();
		
		I2CAgent = new("I2C_agent",this);
		I2CAgent.set_configuration(configuration.I2CCfg);
		I2CAgent.i2c_bus = this.i2c_bus;
		I2CAgent.build();
		
		I2CMBPred = new("pred",this);
		I2CMBPred.set_configuration(configuration);
		
		I2CMBScore = new("scbd",this);
		
		I2CMBCov = new("coverage",this);
		I2CMBCov.set_configuration(configuration);
		
		WAgent.connect_subscriber(I2CMBCov);
		WAgent.connect_subscriber(I2CMBPred);
		
		I2CMBPred.set_scoreboard(I2CMBScore);
		I2CAgent.connect_subscriber(I2CMBScore);
	endfunction
	
	function ncsu_component#(wb_transaction) get_WB_agent();
		return WAgent;
    endfunction

    function ncsu_component#(i2c_transaction) get_I2C_agent();
		return I2CAgent;
    endfunction
	
	function void set_configuration(i2cmb_env_configuration cfg);
		configuration = cfg;
	endfunction
	
	virtual task run();
		WAgent.run();
		I2CAgent.run();
	endtask
	

endclass