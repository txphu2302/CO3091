`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 04:55:15 PM
// Design Name: 
// Module Name: test_lcd_display
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


module test_lcd_display;
    reg clk;
    reg rst;
    reg [127:0] line1;
    reg [127:0] line2;

    wire rs, rw, en;
    wire [7:0] data;

    LCD_display uut (
        .clk(clk),
        .rst(rst),
        .line1(line1),
        .line2(line2),
        .rs(rs),
        .rw(rw),
        .en(en),
        .data(data)
    );

    initial begin
        clk = 0; rst = 1;
        #10 rst = 0;

        // Gán d? li?u test
        line1 = 128'h20202020657275532061696C204920; // "I am User    "
        line2 = 128'h202020202020206E696D644120616C; // "I am Admin   "

        #1000 $stop;
    end

    always #5 clk = ~clk;
endmodule

