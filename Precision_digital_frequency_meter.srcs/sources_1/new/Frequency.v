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
// Ƶ�ʼ��㹫ʽ��f_in = N_in / N_std �� f_std
// Dependencies: none
// Revision:1.0
// Revision 0.01 - File Created
// Additional Comments:none
// 
//////////////////////////////////////////////////////////////////////////////////


module Frequency(
    input               std_clk,
    input               rst_p,      //Digilent ZYBO������ߵ�ƽ��λ
    input               pause_in,   //�����ź�
    
    output   [31:0]     freq        //�����źŵ�Ƶ��
    );

parameter           GATE_TIME = 32'd2_097_152,    //�ſ�ʱ��2^21�����Ժ�������21λ������ֵԽ���ſ�ʱ��Խ�����ó����������ʱ��Ҳ��Խ���������Ƶ��Ҳ��Խ׼
                     CLK_PARA = 32'd100_000_000;   //��׼ʱ�ӵ�Ƶ�ʣ�100M��
    
    reg             gate_1;//�ſ�ʱ��1
    reg             gate_2;//�ſ�ʱ��2
    reg     [31:0]  cnt_time;//��׼ʱ�Ӽ�����
    reg     [60:0]  cnt_n2;//�����źż�����
    reg             pause_pre;//�����ź�ǰһʱ������״̬
    reg             pause_now;//�����ź��ڵ�ǰʱ���ڵ�
    wire            rising_edge;//�����ر�־�ź�

//�����ؼ��    
assign rising_edge = ~pause_pre & pause_now;

//�����ؼ��    
always @(posedge std_clk or negedge rst_p)begin
    if(rst_p)
        pause_pre <= 1'b0;
    else
        pause_pre <= pause_now;
end

//�����ؼ��
always @(posedge std_clk or negedge rst_p)begin
    if(rst_p)
        pause_now <= 1'b0;
    else
        pause_now <= pause_in;
end
    
//�Ի�׼�ź�Ϊʱ�ӵ���ͨ�ļ�������������GATE_TIME    
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    cnt_time <= 0;
    else if(cnt_time < GATE_TIME) 
    cnt_time <= cnt_time + 32'd1;
    else
    cnt_time <= 32'd0;
end
 
 //�жϼ�������ֵ�Ƿ�ﵽһ����С��gate_2�Ƿ�Ҳͬʱ���Ͷ����߻������ſ��ź�1  
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    gate_1 <= 1'b0;
    else if(cnt_time == GATE_TIME)              //gate_1��������
    gate_1 <= 1'b0;
    else if(gate_2 == 1'b0)                     //gate_1��һ�������������ж��Ǻ����еĺ��ģ���Ϊ�������ź�Ƶ�ʵ��ڻ�׼Ƶ��ʱ��gate_2��ʱ����Ϊʱ�ӵ����⣬
                                                //��gate_1����ʱ��gate_2���������źŵ���һ���������ж�gate_1�Ƿ�͵�ƽ���Ծ����Ƿ�����gate_2�����������ź�ʱ�ӵ�������ʱ����׼ʱ���Ѿ���ȥ�˸�������ڣ�gate_1��gate_2�ж�ǰ���Ѿ��������ˣ�
    gate_1 <= 1'b1;                             //���������ҳ�Ϊʱ�������ص�����
    else                                        //����Ĭ�ϻ����䱾��
    gate_1 <= gate_1;
end

//����gate_1��ֵ�������Ƿ������ſ��ź�2
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

//���������ź����ſ�ʱ���ڵ�������
always @(posedge std_clk or posedge rst_p)begin
    if(rst_p)
    cnt_n2 <= 32'b0;
    else if(gate_2 == 1'b1 && rising_edge == 1'b1) 
    cnt_n2 <= cnt_n2 + 32'd1;
    else if(gate_1 == 1'b1 && rising_edge == 1'b1)
    cnt_n2 <= 32'd0;
    else                            //����else��ֻд����������������䣬����������ж϶�д��else if���������bug����Ҫ͵�����������ҳ�Ϊģ���߼���ȫ��
    cnt_n2 <= cnt_n2;
end

//���������źŵ�Ƶ��
assign  freq = (gate_2 == 1'b0 && gate_1 == 1'b0) ? (cnt_n2 * 100_000_000)>>21 : freq;//����ܴ�cnt_n2λ��Ҫָ���ĺܴ󣬷������100M������

endmodule
