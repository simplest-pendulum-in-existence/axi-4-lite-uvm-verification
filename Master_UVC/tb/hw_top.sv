module hw_top;
  
bit clk, resetn;
  
axi4lite_intf intf(clk, resetn);

always #5 clk = ~clk;  

initial begin
resetn=0;
#10;
resetn=1;
end

endmodule
