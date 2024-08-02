

module tb();
	reg clk,ena,reset;
	wire pm;
        wire [7:0] mm,hh,ss;
	initial
	 clk=0;
	 always #500 clk=~clk;
	
	initial begin
		ena=1;
		reset=0;
	end
   top m1 (
     clk,
     reset,
     ena,
     pm,
     hh,
     mm,
     ss);
endmodule
