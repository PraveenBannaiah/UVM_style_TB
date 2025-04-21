import ncsu_pkg::*;
import wb_pkg::*;
import i2c_pkg::*;
class i2cmb_generator extends ncsu_component#(.T(ncsu_transaction));      //We need to use the brackets in system verilog for parameterised classes
	
	i2c_transaction i2c_trans[192];
	wb_transaction wb_trans[192];
	string trans_name;
	
	ncsu_component #(i2c_transaction) I2C_agent;
	ncsu_component #(wb_transaction) WB_agent;
	
	
	function new(string name = "", ncsu_component #(T) parent = null); 
		super.new(name,parent);
	endfunction

	function void set_agent(ncsu_component #(i2c_transaction) I2C_agent,ncsu_component #(wb_transaction) WB_agent);
       this.I2C_agent = I2C_agent;
	   this.WB_agent = WB_agent;
    endfunction
	
	virtual task run();
		//$display("\n Debug 3");
		fork 
			begin
				foreach (i2c_trans[i]) begin                       //WIll it only go through instantiated objects or eveyrthing?
					if(i2c_trans[i] != null)
						I2C_agent.bl_put(i2c_trans[i]);
				end
			end
			
			begin
				foreach (wb_trans[i]) begin 
					//$display("\n(Generator)i:%d Address:%d   Data:%d",i,wb_trans[i].slave_address, wb_trans[i].write_data);
					if(wb_trans[i] != null)
						WB_agent.bl_put(wb_trans[i]);
				end
			end
		join
	endtask

endclass