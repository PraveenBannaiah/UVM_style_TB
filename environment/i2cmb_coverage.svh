import i2c_pkg::*;
import wb_pkg::*;
import ncsu_pkg::*;

class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

	i2cmb_env_configuration configuration;
	T coverage_transaction;
	
	
	function new(string name = "", ncsu_component_base parent=null);
		super.new(name,parent);
	endfunction
	
	function void nb_put(T trans);
		//$display({get_full_name()," ",trans.convert2string()});
	endfunction
	
	function void set_configuration(i2cmb_env_configuration cfg);
		configuration = cfg;
	endfunction
	
	
endclass