import i2c_pkg::*;
import wb_pkg::*;
import i2cmb_env_pkg::*;
import ncsu_pkg::*;

class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));
		
		ncsu_component#(i2c_transaction) scoreboard;                              //NOt sure if using i2c_transaction is correct
		i2c_transaction transport_trans, input_transaction;
		i2cmb_env_configuration configuration;

		function new(string name = "", ncsu_component #(ncsu_transaction) parent = null);
			super.new(name,parent);
			input_transaction = new();
		endfunction
		
		virtual function void nb_put(T trans);
			//$display({get_full_name()," ",trans.convert2string()});
			input_transaction.address = trans.slave_address;
			input_transaction.monitor_data = trans.monitor_data;
		   scoreboard.nb_transport(.input_trans(input_transaction), .output_trans(transport_trans));
		endfunction
		
		virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);    //NOt sure if using i2c_transaction is correct
			this.scoreboard = scoreboard;
		endfunction
		
		function void set_configuration(i2cmb_env_configuration cfg);
			configuration = cfg;
		endfunction
endclass