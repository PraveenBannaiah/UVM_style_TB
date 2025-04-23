import i2c_pkg::*;
import wb_pkg::*;
import ncsu_pkg::*;

class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

	i2cmb_env_configuration configuration;
	T coverage_transaction;

	bit[7:0] cov_data;
	bit [7:0] cov_address;

	bit[3:0] byte_fsm;
	bit[3:0] bit_fsm;

	covergroup coverage_cg;
		coverpoint cov_data;
		coverpoint cov_address;
	endgroup

	covergroup FSM_coverage;
		BYTE:coverpoint byte_fsm;
		BIT:coverpoint bit_fsm;
		FSM_CROSS:cross BYTE,BIT;
	endgroup
	
	
	function new(string name = "", ncsu_component_base parent=null);
		super.new(name,parent);
		coverage_cg = new;
		FSM_coverage = new;
	endfunction
	
	function void nb_put(T trans);
		//$display({get_full_name()," ",trans.convert2string()});
		cov_data = trans.monitor_data;
		cov_address = trans.slave_address;
		coverage_cg.sample();

		if(trans.slave_address == 8'h03) begin
			byte_fsm = trans.monitor_data[7:4];
			bit_fsm = trans.monitor_data[3:0];
			FSM_coverage.sample();
		end
	endfunction
	
	function void set_configuration(i2cmb_env_configuration cfg);
		configuration = cfg;
	endfunction
	
	
endclass