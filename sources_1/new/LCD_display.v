`timescale 1ns / 1ps
    
    module LCD_display(
        input clk,
        input rst,
        input update,              // Tín hi?u yêu c?u c?p nh?t
        input [3:0] sw_p,
        input [127:0] line1,       // N?i dung dòng 1
        input [127:0] line2,       // N?i dung dòng 2
        input flag_counter,
        output reg rs,
        output reg rw,
        output reg en,
        output reg [7:0] data
       
    );
    
        reg [3:0] state;
        reg [27:0] delay_counter;
        reg [4:0] char_index; // Index for characters (0 to 15 for each line)
    
        // States for FSM
        localparam INIT        = 4'd0;
        localparam DISPLAY_ON  = 4'd1;
        localparam CLEAR_ON    = 4'd2;
        localparam SET_CURSOR1 = 4'd3;
        localparam WRITE_LINE1 = 4'd4;
        localparam SET_CURSOR2 = 4'd5;
        localparam WRITE_LINE2 = 4'd6;
        localparam IDLE        = 4'd7;
        localparam CHECK_UPDATE = 4'd8; // Thêm tr?ng thái ki?m tra c?p nh?t

    
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                rs <= 0; rw <= 0; en <= 0;
                data <= 8'b0;
                state <= INIT;
                delay_counter <= 0;
                char_index <= 0;
            end else begin
                delay_counter <= delay_counter + 1;
                case (state)
                    INIT: begin
                        if (delay_counter <= 50000) begin
                            en <= 1; rs <= 0; rw <= 0; data <= 8'b00111000; // Function set: 8-bit, 2-line
                        end else if (delay_counter < 100000) begin
                            en <= 0;
                        end else begin
                            delay_counter <= 0;
                            state <= DISPLAY_ON;
                        end
                    end
    
                    DISPLAY_ON: begin
                        if (delay_counter <= 50000) begin
                            en <= 1; rs <= 0; rw <= 0; data <= 8'b00001100; // Display on, cursor off
                        end else if (delay_counter < 100000) begin
                            en <= 0;
                        end else begin
                            delay_counter <= 0;
                            state <= CLEAR_ON;
                        end
                    end
    
                    CLEAR_ON: begin
                        if (delay_counter <= 50000) begin
                            en <= 1; rs <= 0; rw <= 0; data <= 8'b00000001; // Clear display
                        end else if (delay_counter < 100000) begin
                            en <= 0;
                        end else begin
                            delay_counter <= 0;
                            state <= SET_CURSOR1;
                        end
                    end
    
                    SET_CURSOR1: begin
                        if (delay_counter <= 50000) begin
                            en <= 1; rs <= 0; rw <= 0; data <= 8'b10000000; // Set DDRAM address to 0x00 (Line 1)
                        end else if (delay_counter < 100000) begin
                            en <= 0;
                        end else begin
                            delay_counter <= 0;
                            state <= WRITE_LINE1;
                        end
                    end
    
                    WRITE_LINE1: begin
                        if (char_index < 16) begin
                            if (delay_counter <= 50000) begin
                                en <= 1; rs <= 1; rw <= 0; data <= (line1 >> (8 * (15 - char_index))) & 8'hFF; // G?i k? t? t? line1
                            end else if (delay_counter < 100000) begin
                                en <= 0;
                            end else begin
                                delay_counter <= 0;
                                char_index <= char_index + 1;
                            end
                        end else begin
                            delay_counter <= 0;
                            char_index <= 0;
                            state <= SET_CURSOR2;
                        end
                    end
    
                    SET_CURSOR2: begin
                        if (delay_counter <= 50000) begin
                            en <= 1; rs <= 0; rw <= 0; data <= 8'b11000000; // Set DDRAM address to 0x40 (Line 2)
                        end else if (delay_counter < 100000) begin
                            en <= 0;
                        end else begin
                            delay_counter <= 0;
                            state <= WRITE_LINE2;
                        end
                    end
    
                    WRITE_LINE2: begin
                        if (char_index < 16) begin
                            if (delay_counter <= 50000) begin
                                en <= 1; rs <= 1; rw <= 0; data <= (line2 >> (8 * (15 - char_index))) & 8'hFF; // G?i k? t? t? line2
                            end else if (delay_counter < 100000) begin
                                en <= 0;
                            end else begin
                                delay_counter <= 0;
                                char_index <= char_index + 1;
                            end
                        end else begin
                            delay_counter <= 0;
                            char_index <= 0;
                            state <= IDLE;
                        end
                    end
    
                    IDLE: begin
                        en <= 0;
                        if (update || sw_p[0] || sw_p[1] || sw_p[2] || sw_p[3]) begin
                            state <= CHECK_UPDATE;
                            delay_counter <= 0;
                        end
                        else if (!update || !sw_p[0] || !sw_p[2] || !sw_p[3]) begin
                            state <= CHECK_UPDATE;
                            delay_counter <= 0;
                        end
                    end
        
                    CHECK_UPDATE: begin
                        // Quay l?i SET_CURSOR1 ?? ghi n?i dung m?i
                       // state <= SET_CURSOR1;
                       if(delay_counter >= 12500000) begin
                         state <= CLEAR_ON;
                         delay_counter <= 0;
                        end
                    end
                endcase
            end
        end
    endmodule