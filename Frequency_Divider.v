module  Frequency_Divider
#(parameter TARGET_FREQUENCY = 1000000)
(  // Inclk = 50Mhz
	input  Inclk,	
	output reg Outclk
);

	localparam MAX_COUNT = ( 50000000 / (TARGET_FREQUENCY * 2) );
	
	localparam COUNTER_SIZE = log2(MAX_COUNT);

	reg [COUNTER_SIZE-1:0] count;

	always @(posedge Inclk)
	begin
		if(count == (MAX_COUNT -1))
		begin
			count  <= 0;
			Outclk <= ~Outclk;
		end
		else
			count <= count + 1;
		
	end	
	
	function integer log2(input integer m);
		integer i;
		begin
			log2 = 1;
			for (i=0; 2**i < m ;i=i+1)
				log2 = i + 1;
		end
	endfunction
	
endmodule
