// Code your design here
module add( output reg [4:0] sum,
           input [3:0] a,
           input [3:0] b,
 		    input clk);
 
  always @ (posedge clk) begin
    sum<= a+b;   
  end
endmodule
