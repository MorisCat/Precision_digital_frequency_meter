`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: FPGA Lab
// Engineer: Mingshuo_Liu
// 
// Create Date: 2021/10/15 17:00:47
// Design Name: Precision_digital_frequency_meter
// Module Name: Frequency
// Project Name: Precision_digital_frequency_meter
// Target Devices: zynq7000
// Tool Versions: 2018.3
// Description: 
// 频率计算公式：f_in = N_in / N_std × f_std
// Dependencies: none
// Revision:1.0
// Revision 0.01 - File Created
// Additional Comments:none
// 
//////////////////////////////////////////////////////////////////////////////////


module Frequency(
    input               std_clk,
    input               rst_p,      //Digilent ZYBO开发板高电平复位
    input               pause_in,   //输入信号
    
    output   [31:0]     freq        //输入信号的频率
    );

parameter           GATE_TIME = 32'd2_097_152,    //门控时间2^21，所以后面右移21位，该数值越大，门控时间越长，得出测量结果的时间也就越长，测出的频率也就越准
                     CLK_PARA = 32'd100_000_000;   //基准时钟的频率（100M）
    
    reg             gate_1;//门控时间1
    reg             gate_2;//门控时间2
    reg     [31:0]  cnt_time;//基准时钟计数器
    reg     [60:0]  cnt_n2;//输入信号计数器
    reg             pause_pre;//输入信号前一时钟周期状态
    reg             pause_now;//输入信号在当前时钟内的
    wire            rising_edge;//上升沿标志信号

//上升沿检测    
assign rising_edge = ~pause_pre & pause_now;

//上升沿检测    
always @(posedge std_clk or negedge rst_p)begin
    if(rst_p)
        pause_pre <= 1'b0;
    else
        pause_pre <= pause_now;
end

//上升沿检测
always @(posedge std_clk or negedge rst_p)begin
    if(rst_p)
        pause_now <= 1'b0;
    else
        pause_now <= pause_in;
end
    
//以基准信号为时钟的普通的计数器，计数到GATE_TIME    
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    cnt_time <= 0;
    else if(cnt_time < GATE_TIME) 
    cnt_time <= cnt_time + 32'd1;
    else
    cnt_time <= 32'd0;
end
 
 //判断计数器的值是否达到一定大小及gate_2是否也同时拉低而拉高或拉低门控信号1  
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    gate_1 <= 1'b0;
    else if(cnt_time == GATE_TIME)              //gate_1置零条件
    gate_1 <= 1'b0;
    else if(gate_2 == 1'b0)                     //gate_1归一条件，此条件判断是核心中的核心，因为当输入信号频率低于基准频率时，gate_2有时会因为时钟的问题，
                                                //（gate_1拉低时，gate_2会在输入信号的下一个上升沿判断gate_1是否低电平，以决定是否拉低gate_2，但是输入信号时钟到上升沿时，基准时钟已经过去了更多的周期，gate_1在gate_2判断前就已经被拉高了）
    gate_1 <= 1'b1;                             //上述问题我称为时钟周期重叠问题
    else                                        //否则默认还是其本身
    gate_1 <= gate_1;
end

//根据gate_1的值来决定是否拉高门控信号2
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    gate_2 <= 1'b0;
    else if(gate_1 == 1'b1 && rising_edge == 1'b1)
    gate_2 <= 1'b1;
    else if(rising_edge == 1'b1)
    gate_2 <= 1'b0;
    else
    gate_2 <= gate_2;
end

//计数输入信号在门控时间内的周期数
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    cnt_n2 <= 32'b0;
    else if(gate_2 == 1'b1 && rising_edge == 1'b1) 
    cnt_n2 <= cnt_n2 + 32'd1;
    else if(gate_1 == 1'b1 && rising_edge == 1'b1)
    cnt_n2 <= 32'd0;
    else                            //尽量else里只写等于它本身这条语句，其他的情况判断都写在else if里，否则会出现bug，不要偷懒，该问题我称为模块逻辑健全性
    cnt_n2 <= cnt_n2;
end

//计算输入信号的频率
assign  freq = (gate_2 == 1'b0 && gate_1 == 1'b0) ? (cnt_n2 * 100_000_000)>>21 : freq;//这里很大，cnt_n2位宽要指定的很大，否则乘以100M后会溢出

endmodule
