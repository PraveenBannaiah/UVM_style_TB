import ncsu_pkg::*;
class i2c_transaction extends ncsu_transaction;
	
	logic op;
	bit [7:0] received_data[];
	bit [7:0] sending_data;
	bit [7:0] monitor_data;
	logic [7:0] address;
	logic transfer_complete;

	function new(string name = "" );
		super.new(name);                     //We can access the name and ID from variables defined in ncsu_transaction
	endfunction
	
	virtual function string convert2string();
        return $sformatf("name: %s transaction_count: %0d ",name,transaction_id);
	endfunction
	
	
	function bit compare(i2c_transaction rhs);
		return ((this.monitor_data  == rhs.monitor_data ) && 
            (this.address == rhs.address) &&
            (this.op == rhs.op) );
    endfunction
	
endclass