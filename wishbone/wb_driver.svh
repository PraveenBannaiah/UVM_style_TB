class wb_driver extends ncsu_component#(.T(wb_transaction));

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
  endfunction

  virtual wb_if #(2,8) wb_bus; 
  T wb_trans;
  wb_configuration configuration;
  

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    //$display({get_full_name()," ",trans.convert2string()});
	if(trans.single_trans == 1) begin
		if(trans.single_trans_op == 1)
		begin
			wb_bus.master_read(trans.slave_address,trans.read_data);
			//$display("Single register(%x) byte read: %x",trans.slave_address,trans.read_data);
		end
		
		else
			begin 
				wb_bus.master_write(trans.slave_address,trans.write_data);
				//$display("\n Debug 1");
				//if(trans.slave_address == 8'h02)
					//wb_bus.wait_for_interrupt();
			end
	end
    else begin
	
		if(trans.op == 1)
			read(trans);
		else
			write(trans);
	end
  endtask
  
  
  task read(wb_transaction tr);
		//$display("\n Reached Read");
		wb_bus.master_write(8'h00,8'b11xxxxxx);        //Writing to CSR bit
		
		
		wb_bus.master_write(8'h01,8'h00);               //Write byte 0x00 to the DPR. This is the ID of desired I2C bus.
		wb_bus.master_write(8'h02,8'bxxxxx110);         //Set Bus
		
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);
		
		wb_bus.master_write(8'h02,8'bxxxxx100);          //// Write byte “xxxxx100” to the CMDR. This is start command.
		
		//$display("\n Read debug 1");
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //We are reading to pull the irq to zero, i think
		 
		tr.slave_address = (tr.slave_address << 1) + 1'b1;    //address manipulation
		wb_bus.master_write(8'h01,tr.slave_address);              //This is the slave address 0x44 shifted 1 bit to the left + rightmost bit is '1' which means reading.
		wb_bus.master_write(8'h02,8'bxxxxx001);        //Write byte “xxxxx001” to the CMDR. This is Write command.     
		
		//$display("\n Read debug 2");
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		 
		wb_bus.master_write(8'h02,8'bxxxxx011);           //Write byte “xxxxx011” to the CMDR. This is Read With Nak command.
		
		//$display("\n Read debug 3");
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		  
		wb_bus.master_read(8'h01,tr.read_data);           //Read DPR to get received byte of data.
		wb_bus.master_write(8'h02,8'bxxxxx101);        //Write byte “xxxxx101” to the CMDR. This is Stop command.

		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		
	endtask
	
	task write(wb_transaction tr);
		//$display("\n Reached Write");
		wb_bus.master_write(8'h00,8'b11xxxxxx);           //Example1 write to CSR reg       //THIS IS IMPORTANT TO ENABLE I2C
		wb_bus.master_write(8'h01,8'h00);               //Write byte 0x00 to the DPR. This is the ID of desired I2C bus.
		wb_bus.master_write(8'h02,8'bxxxxx110);         // Write byte “xxxxx110” to the CMDR. This is Set Bus command.                 
			
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		

		wb_bus.master_write(8'h02,8'bxxxxx100);          //// Write byte “xxxxx100” to the CMDR. This is start command.
		
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		
		tr.slave_address = (tr.slave_address << 1);
		wb_bus.master_write(8'h01,tr.slave_address);               //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left + rightmost bit = '0', which means writing.
		wb_bus.master_write(8'h02,8'bxxxxx001);        //Write byte “xxxxx001” to the CMDR. This is Write command.  

		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		 
		wb_bus.master_write(8'h01,tr.write_data);                // Write byte  to the DPR. This is the byte to be written.
		wb_bus.master_write(8'h02,8'bxxxxx001);        // Write byte “xxxxx001” to the CMDR. This is Write command.

		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'  //WE need to read to get the irq to go down again
		

		wb_bus.master_write(8'h02,8'bxxxxx101);        //Write byte “xxxxx101” to the CMDR. This is Stop command.
		
		wb_bus.wait_for_interrupt();
		wb_bus.master_read(8'h02,tr.read_data);             //Wait for interrupt or until DON bit of CMDR reads '1'
		
		
	endtask

endclass
