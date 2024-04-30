`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/30 21:23:18
// Design Name: 
// Module Name: BREATH_LED_TB
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


module BREATH_LED_TB();
    reg clk_reg;
    reg rstn_reg;
    wire [3:0]led;
    
    wire clk;
    wire rstn;
    
    initial begin
    clk_reg=0;
    rstn_reg=0;
    #10
    rstn_reg=1;
    end
    
    always #1 clk_reg=~clk_reg;
    assign rstn=rstn_reg;
    assign clk=clk_reg;
    BREATH_LED #
    (
    .CLOCK_FRQ(1000000) //TEST 1Mhz
    )
    BREATH_LED_INST
    (
    .CLK(clk),
    .RSTN(rstn),
    .LED(led)
    );
endmodule
