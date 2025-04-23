
interface i2c_if #(int I2C_ADDR_WIDTH = 7,int I2C_DATA_WIDTH = 8) ( input SCL, inout triand SDA);   //Try because 
	
                     //Where should we declare this

	property valid_sda_on_scl_posedge;
		@(posedge SCL) (!$isunknown(SDA));                                
	endproperty 

	assert property(valid_sda_on_scl_posedge);
	
	

	//In top.sv we will have an initial block, so its a intial block inside another initial?!
	bit [6:0] address;
	logic start_condition, stop_condition;
	logic [4:0] no_of_bytes;
	//typedef enum {Write, Read} i2c_op_t;
	logic global_op;
	logic transfer_complete_local;
	logic sda_drive;
	logic local_drive;
	bit [7:0] global_data[1];
	
	logic [7:0] read_data_memory[96];
	int read_byte_pointer;
	
	
	initial begin:memory
		read_byte_pointer = 0;
		read_data_memory[0] = 8'h64;
		for(int i=1;i<32;i++)
			read_data_memory[i] = read_data_memory[i - 1] + 1'b1; 
			
		read_data_memory[32] = 8'h3F;
		for(int i=33;i<96;i++)
			read_data_memory[i] = read_data_memory[i - 1] - 1'b1;
			
		end
	
	initial sda_drive =0;
	
	assign SDA = sda_drive?local_drive:1'bz;
	
	//What if some simulation time as passed before calling this task, will this initial block run as initial blocks run only at 0ns? 
	initial begin
	start_condition =0;
	stop_condition = 0;
	no_of_bytes = 0;
	end

	always@(negedge SDA) begin                                   //In a way this is wrong 
		if(SCL)
			start_condition = 1;
	end


	task wait_for_i2c_transfer ( output bit op, output bit[I2C_DATA_WIDTH - 1: 0] write_data[]);     //use new to assign memory to write data each time
	
		//for(int i =0 ;i<I2C_DATA_WIDTH;i++)
		//	write_data[no_of_bytes][i] = i;                    //Initialising values? IDK?
	
		 
		//@(negedge SDA) begin                                   //In a way this is wrong 
		//	if(SCL)
		//		start_condition = 1;
		//end
		
		//$display("\n Reached Wait for I2C");
		
		@(start_condition);
		
		if(start_condition)  begin                                //waits for start condition to go high, if start condition is already high then it waits for it to go down and up again 
			//$display("\n start condition received");
			//for(int i =0 ;i<I2C_ADDR_WIDTH;i++) begin
				
			@(posedge SCL)
			address[6] = SDA;     
				
			@(posedge SCL)
			address[5] = SDA;
			
			@(posedge SCL)
			address[4] = SDA;
			
			@(posedge SCL)
			address[3] = SDA;
			
			@(posedge SCL)
			address[2] = SDA;
			
			@(posedge SCL)
			address[1] = SDA;
			
			@(posedge SCL)
			address[0] = SDA;
				
				
			//foreach(address[i]) 
			//$display("\naddress:%X",address);	
				
			//while(stop_condition != 1) begin
			@(posedge SCL);
			op = SDA;
			
			
			@(posedge SCL);
			sda_drive = 1;
			local_drive = 0;
			//SDA <= 0;                  //Acknowledgement 
			
			@(negedge SCL)
			sda_drive = 0;

			
			if(op == 1) begin               //1 represents read
			//$display("\n Read operation received");
				//while(transfer_complete_local != 1)
					provide_read_data(.read_data(write_data),.transfer_complete(transfer_complete_local));
			end
					
			else if(op == 0) begin
				
				write_data = new[write_data.size() + 1](write_data);                      //Dynamic allocation of the array
				//$display("\n Write operation received");
				
				//for(int i =0 ;i<I2C_DATA_WIDTH;i++) begin
				@(posedge SCL)
				write_data[no_of_bytes][7] = SDA;  
				
				@(posedge SCL)
				write_data[no_of_bytes][6] = SDA;
				
				@(posedge SCL)
				write_data[no_of_bytes][5] = SDA;
				
				@(posedge SCL)
				write_data[no_of_bytes][4] = SDA;
				
				@(posedge SCL)
				write_data[no_of_bytes][3] = SDA;
				
				@(posedge SCL)
				write_data[no_of_bytes][2] = SDA;
				
				@(posedge SCL)
				write_data[no_of_bytes][1] = SDA;
				
				@(posedge SCL)
				write_data[no_of_bytes][0] = SDA;
					
					
				//$display("\nwrite_data:%X and byte:%d",write_data[no_of_bytes],no_of_bytes);
				
				no_of_bytes += 1;
					
				@(posedge SCL)
				sda_drive = 1;
				local_drive = 0;
										//Acknowledgement 
				@(negedge SCL)
				sda_drive = 0;
					
				end
					
			@(posedge SDA) begin                 
				if(SCL == 1'b1) begin
					stop_condition = 1;
					//$display("\n Stop condition received");
					start_condition =0;
				end
			end
			
			start_condition =0;
			stop_condition = 0;
		
		end
			
	endtask
	
	
	task provide_read_data( input bit[I2C_DATA_WIDTH - 1:0] read_data [], output bit transfer_complete);
		
		//$display("\n Data about to be sent:%X",read_data[no_of_bytes]);
		//for(int i=0;i<I2C_DATA_WIDTH;i++) begin
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][7]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][6]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][5]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][4]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][3]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][2]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][1]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
		 
		 
		@(posedge SCL)                         
		local_drive = (read_data_memory[read_byte_pointer][0]);                       //For now lets write the same value
		sda_drive = 1;
					
		@(negedge SCL)
		 sda_drive = 0;
													//Wishbone read does not give ack it give nack, so the master will set the SDA to 1 after read
			 
		read_byte_pointer = read_byte_pointer + 1;
			//end
		
		@(posedge SCL)
		if(SDA == 1) begin                      //The master sending positive acknowledgement, the master will not send ACK, it will send NACK
			transfer_complete = 0;         //Meaning it wants to read more data
			//$display("\n Acknowledgement from master received");         //Basically a NACk
		end
		else begin
			transfer_complete = 1;         //use it however you feel like it
			//$display("|n NO ack from master"); 
			
		end
	
	endtask
	
	
	
	task monitor(output bit[I2C_ADDR_WIDTH - 1:0] addr, output bit op_type, output bit[I2C_DATA_WIDTH - 1:0] data, output bit flag);
	
			@(start_condition);                                //Maybe posedge 
			//$display("\n The start condition received");
			if(start_condition)  begin
			flag = 1'b1;                                       //Because monitor was printing twice
			
			@(posedge SCL)
			addr[6] = SDA;     
				
			@(posedge SCL)
			addr[5] = SDA;
			
			@(posedge SCL)
			addr[4] = SDA;
			
			@(posedge SCL)
			addr[3] = SDA;
			
			@(posedge SCL)
			addr[2] = SDA;
			
			@(posedge SCL)
			addr[1] = SDA;
			
			@(posedge SCL)
			addr[0] = SDA;
			
				
			@(posedge SCL);
			op_type = SDA;      
			
			
			@(posedge SCL);             //Acknowledgement
			
			//data = new[data.size() + 1];
			if(op_type == 0) begin      //Write operation
			
				//$display("\n I2C_BUS WRITE Transfer");                      
				
				//for(int i =0 ;i<I2C_DATA_WIDTH;i++) begin
				@(posedge SCL)
				data[7] = SDA;  
				
				@(posedge SCL)
				data[6] = SDA;
				
				@(posedge SCL)
				data[5] = SDA;
				
				@(posedge SCL)
				data[4] = SDA;
				
				@(posedge SCL)
				data[3] = SDA;
				
				@(posedge SCL)
				data[2] = SDA;
				
				@(posedge SCL)
				data[1] = SDA;
				
				@(posedge SCL)
				data[0] = SDA;
			
			end
			
			else begin
				//$display("\n I2C_BUS READ Transfer");
				@(posedge SCL)
				data[7] = read_data_memory[read_byte_pointer][7];
				
				@(posedge SCL)
				data[6] = read_data_memory[read_byte_pointer][6];
				
				@(posedge SCL)
				data[5] = read_data_memory[read_byte_pointer][5];
				
				@(posedge SCL)
				data[4] = read_data_memory[read_byte_pointer][4];
				
				@(posedge SCL)
				data[3] = read_data_memory[read_byte_pointer][3];
				
				@(posedge SCL)
				data[2] = read_data_memory[read_byte_pointer][2];
				
				@(posedge SCL)
				data[1] = read_data_memory[read_byte_pointer][1];
				
				@(posedge SCL)
				data[0] = read_data_memory[read_byte_pointer][0];
				
			end
			
			
			@(posedge SCL);         //Acknowledgement 
			
			@(posedge SCL);          //Stop condition
			
		end
		
		else
			flag = 1'b0;
		
			
	
	endtask
	
endinterface 