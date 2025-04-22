import ncsu_pkg::*;
class wb_transaction extends ncsu_transaction;
	
    logic op;
	bit we;
	bit [7:0] monitor_data;
	rand bit [7:0] write_data;
	bit [7:0] read_data;
	rand logic [7:0] slave_address;
	logic transfer_complete;
    bit single_trans;
	rand bit single_trans_op;

	function new(string name = "" );
		super.new(name);                     //We can access the name and ID from variables defined in ncsu_transaction
	endfunction
	
	virtual function string convert2string();
        return $sformatf("name: %s transaction_count: %0d ",name,transaction_id);
	endfunction
	
	function bit compare(wb_transaction rhs);
    return ((this.op  == rhs.op ) && 
            (this.monitor_data == rhs.monitor_data) &&
            (this.slave_address == rhs.slave_address) );
	endfunction
	
endclass