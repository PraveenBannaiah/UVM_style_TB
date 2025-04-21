import i2c_pkg::*;
import wb_pkg::*;
import ncsu_pkg::*;
import i2cmb_env_pkg::*;

class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));
	
	T trans_in;
	T trans_out;
	
	function new(string name="", ncsu_component #(ncsu_transaction) parent = null);
		super.new(name,parent);
	endfunction
	
	function void nb_put(T trans);
		//$display({get_full_name()," ADDRESS:%d    DATA:%d   OP:%d",trans.address,trans.monitor_data, trans.op});          //need to compare
		//$display("\n (I2C Scoreboard) ADDRESS:%d    DATA:%d   OP:%d",trans.address,trans.monitor_data, trans.op);
		ncsu_info(get_full_name(), $sformatf("ADDRESS:%d    DATA:%d   OP:%d", trans.address, trans.monitor_data, trans.op), NCSU_NONE);

	endfunction

    virtual function void nb_transport(input T input_trans, output T output_trans);
		//$display({get_full_name()," nb_transport: expected transaction ",input_trans.convert2string()});
		this.trans_in = input_trans;
		output_trans = trans_out;
    endfunction

endclass