`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/15 18:53:14
// Design Name: 
// Module Name: tbfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/17 21:10:39
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tbfile();

reg sys_clk; 
reg sys_rst_p;
reg pause_in;
wire freq;
 
initial begin
sys_clk <= 1'b1;
pause_in <= 1'b1;
sys_rst_p<= 1'b1;
#20
sys_rst_p <= 1'b0;
end

always #5 sys_clk = ~sys_clk;
always #15 pause_in = ~pause_in;

Frequency u0_Top(
.std_clk    (sys_clk ),
.rst_p      (sys_rst_p),
.pause_in   (pause_in),

.freq       (freq)
);
endmodule
