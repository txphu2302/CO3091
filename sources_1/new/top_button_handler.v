`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 11:12:59 AM
// Design Name: 
// Module Name: top_button_handler
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


module top_button_handler(
    input wire clk,
    input wire rst,
    input wire [3:0] btn,               // 4 nut nhan dau vao
    input wire [3:0] sw_p,              // Chon san pham
    input wire sw_au,                   // Chuyen doi che do (0: user, 1: admin)
    input wire update_money,
    output reg [3:0] seg_0_data,        // Hang don vi
    output reg [3:0] seg_1_data,        // Hang chuc
    output reg [3:0] seg_2_data,        // Hang tram
    output reg [3:0] seg_3_data,         // Hang nghin
    output wire rs, rw, en,
    output reg [3:0] led,
    output wire [7:0] data
);
    reg [7:0] product_count_ready[4:0]; // Mang luu so luong san pham da co(4 san pham)
    reg [7:0] money;               // So tien cua user
    reg [7:0] price[4:0];              // Gia san pham
    reg [7:0] price_to_pay;               //Gia san pham phai tra
    reg [7:0] unit;               //Hang don vi cua tien
    reg [7:0] dozen;               //Hang chuc cua tien
    reg [7:0] product_count_current;      // So san pham muon mua
    reg [7:0] selected_product;           // Chi so san pham duoc chon
    reg [3:0] flag_led;
    integer i;                          // Loop
    reg [127:0] lcd_line1;              // Flattened array
    reg [127:0] lcd_line2;               // Flattened array
    reg [31:0] counter;
    reg [1:0] flag_counter;
    reg [7:0] count_down;
    
    // Tin hieu nut nhan sau khi debounce
    wire btn0_flag, btn1_flag, btn2_flag, btn3_flag;
    

    // Module debounce cho 4 nut nhan
    button_debounce db0 (.clk(clk), .rst(rst), .button_in(btn[0]), .button_flag(btn0_flag));
    button_debounce db1 (.clk(clk), .rst(rst), .button_in(btn[1]), .button_flag(btn1_flag));
    button_debounce db2 (.clk(clk), .rst(rst), .button_in(btn[2]), .button_flag(btn2_flag));
    button_debounce db3 (.clk(clk), .rst(rst), .button_in(btn[3]), .button_flag(btn3_flag));
    
    LCD_display lcd_inst (
        .clk(clk),
        .rst(rst),
        .line1(lcd_line1),
        .line2(lcd_line2),
        .rs(rs),
        .rw(rw),
        .en(en),
        .data(data),
        .update(sw_au),
        .sw_p(sw_p),
        .flag_counter(flag_counter)
    );

    always @(posedge clk) begin
    
        case (sw_p)
            4'b0001: begin
                selected_product = 8'd0; // sw_p[0]
                flag_led = 4'b0001;
            end
            4'b0010: begin
                selected_product = 8'd1; // sw_p[1]
                flag_led = 4'b0010;
            end
            4'b0100: begin
                selected_product = 8'd2; // sw_p[2]
                flag_led = 4'b0100;
            end
            4'b1000: begin
                selected_product = 8'd3; // sw_p[3]
                flag_led = 4'b1000;
            end
            4'b0000: begin
                selected_product = 8'd4;
                flag_led = 4'b0000;
            end 
            default: begin
                selected_product = 8'd5; // Mac dinh
                flag_led = 4'b0000;
            end
            
        endcase
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            money = 8'd0;
            price[0] = 8'd0; // San pham 1
            price[1] = 8'd0; // San pham 2
            price[2] = 8'd0; // San pham 3
            price[3] = 8'd0; // San pham 4
            price[4] = 8'd0; // Mac dinh
            counter = 32'd0;
            flag_counter = 1'b0;
            product_count_current = 8'd0;
            price_to_pay = 8'd0;
            count_down = 8'd0;
            unit = 8'd0;
            dozen = 8'd0;
            for (i = 0; i <= 4; i = i + 1) begin
                product_count_ready[i] = 8'd0; // Reset so luong san pham
            end
           lcd_line1 <= 128'd0; // ??t gi? tr? m?c ??nh cho d?ng LCD 1
           lcd_line2 <= 128'd0; // ??t gi? tr? m?c ??nh cho d?ng LCD 2
        end else begin
            // LED 7 - segment luon hien thi tien cua user
            seg_0_data <= money % 10;
            seg_1_data <= (money / 10) % 10;
            // Hien thi tien phai tra
            seg_2_data <= (money / 100) % 10;
            seg_3_data <= (money / 1000) % 10;
             // Phan biet che do
            if (sw_au == 0) begin
                // Che do user
               
                if (selected_product != 4 && selected_product != 5) begin
                    if(flag_counter == 1) begin
                         //SUCCESS
                         lcd_line1 <= {8'h20, 8'h20, 8'h20, 8'h20, 8'h53, 8'h55, 8'h43, 8'h43, 8'h45, 8'h53, 8'h53, 8'h21, 8'h20, 8'h20, 8'h20, 8'h20}; 
                         lcd_line2 <= {8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h36 - count_down, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20};
     
                         if(counter < 625000000) begin
                            if (counter % 125000000 == 0) begin
                                count_down <= count_down + 1;
                                if (led != 4'b0000)
                                    led = 4'b0000;
                                else led = flag_led;
                            end
                            counter <= counter + 1;
                         end else begin
                            counter <= 0;
                            flag_counter <= 0;
                            count_down <= 0;
                            led <= 4'b0000;
                         end
                    end else if (flag_counter == 2) begin
                        // NOT ENOUGH MONEY
                        lcd_line1 <= {8'h4E, 8'h4F, 8'h54, 8'h20, 8'h45, 8'h4E, 8'h4F, 8'h55, 8'h47, 8'h48, 8'h20, 8'h4D, 8'h4F, 8'h4E, 8'h45, 8'h59};
                        lcd_line2 <= {8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h36 - count_down, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20};
                        if(counter < 625000000) begin
                             if (counter % 125000000 == 0)
                               count_down <= count_down + 1;
                            counter <= counter + 1;
                         end else begin
                            counter <= 0;
                            flag_counter <= 0;
                            count_down <= 0;
                         end
                       end                 
                    if (btn0_flag) begin
                        if (product_count_current < 9 && product_count_current < product_count_ready[selected_product])
                            product_count_current = product_count_current + 1;
                        price_to_pay = price[selected_product] * product_count_current;
                        unit = price_to_pay % 10;
                        dozen = price_to_pay / 10;
                    end
                    
                    if (btn1_flag) begin
                        if (product_count_current > 0)
                            product_count_current = product_count_current - 1;
                        price_to_pay = price[selected_product] * product_count_current;
                        unit = price_to_pay % 10;
                        dozen = price_to_pay / 10;
                    end

                    if (btn2_flag && product_count_ready[selected_product] > 0) begin
                         if (money >= price_to_pay && product_count_current > 0) begin
                             money = money - price_to_pay;
                             product_count_ready[selected_product] = product_count_ready[selected_product] - product_count_current;
                             product_count_current = 0;
                             price_to_pay = 0;
                             unit = 0;
                             dozen = 0;
                             flag_counter <= 1;
                         end
                         else if (product_count_current > 0) flag_counter <= 2;
                    end
                    
                    if (flag_counter == 0) begin
                        lcd_line1 = {8'h52, 8'h65, 8'h61, 8'h64, 8'h79, 8'h3A, 8'h30 + product_count_ready[selected_product],  // "Ready:0"
                                     8'h20, 8'h50, 8'h72, 8'h69, 8'h63, 8'h65, 8'h3A, 8'h30 + price[selected_product], 8'h20};  // " Price:0"
                        if (price_to_pay < 10) begin
                            lcd_line2 = {8'h43, 8'h6F, 8'h75, 8'h6E, 8'h74, 8'h3A, 8'h30 + product_count_current,  // "Count:0"
                                        8'h20, 8'h50, 8'h72, 8'h69, 8'h63, 8'h65, 8'h3A, 8'h30 + price_to_pay, 8'h20};  // " Price:0"
                        end
                        else begin
                            lcd_line2 = {8'h43, 8'h6F, 8'h75, 8'h6E, 8'h74, 8'h3A, 8'h30 + product_count_current,  // "Count:0"
                                        8'h20, 8'h50, 8'h72, 8'h69, 8'h63, 8'h65, 8'h3A, 8'h30 + dozen , 8'h30 + unit};  // " Price:0"
                        end
                    end
                end
                
                else if(selected_product == 4) begin //Nap tien
                    if (btn0_flag && money < 9995) money <= money + 5;
                    if (btn1_flag && money < 9990) money <= money + 10;
                    if (btn2_flag) money <= 0;

                    lcd_line1 = {8'h50, 8'h31, 8'h3A, 8'h30 + price[0], 8'h24, 8'h5F, 8'h30 + product_count_ready[0], // P1: 1$_0
                                 8'h20, 8'h20, 
                                 8'h50, 8'h32, 8'h3A, 8'h30 + price[1], 8'h24, 8'h5F, 8'h30 + product_count_ready[1]};  // 2: 2$_0
                    
                    lcd_line2 = {8'h50, 8'h33, 8'h3A, 8'h30 + price[2], 8'h24, 8'h5F, 8'h30 + product_count_ready[2], // 3: 5$_0
                                 8'h20, 8'h20,
                                 8'h50, 8'h34, 8'h3A, 8'h30 + price[3], 8'h24, 8'h5F, 8'h30 + product_count_ready[3]};  //  4: 9$_0

                end
                else if(selected_product == 5) begin //hien chu ONLY_1_SWITCH_ON 
                    lcd_line1 = {8'h4F, 8'h4E, 8'h4C, 8'h59, 8'h5F, 8'h31, 8'h5F, 8'h53, 8'h57, 8'h49, 8'h54, 8'h43, 8'h48, 8'h5F, 8'h4F, 8'h4E};
                    
                    lcd_line2 = {8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20,
                                 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20};
                end
               
            end else begin
                // Che do admin
                 price_to_pay <= 0;
                 product_count_current <= 0;
                if (selected_product != 4 && selected_product != 5) begin
                    if (btn0_flag) begin
                        if (price[selected_product] < 9)
                            price[selected_product] <= price[selected_product] + 1;
                    end
                    else if (btn1_flag) begin
                         if (price[selected_product] > 1)
                            price[selected_product] <= price[selected_product] - 1;
                    end
                    else if (btn2_flag) begin
                        if (product_count_ready[selected_product] < 9) begin
                            product_count_ready[selected_product] <= product_count_ready[selected_product] + 1; 
                        end
                    end
                    else if (btn3_flag) begin
                        price[selected_product] <= 0;
                        product_count_ready[selected_product] <= 0;
                    end
                    lcd_line1 <= {8'h20, 8'h20, 8'h41, 8'h44, 8'h4D, 8'h49, 8'h4E, 8'h20, 8'h4D, 8'h4F, 8'h44, 8'h45, 8'h20, 8'h31 + selected_product, 8'h20, 8'h20};
                    lcd_line2 <= {8'h50, 8'h72, 8'h69, 8'h63, 8'h65, 8'h3A, 8'h30 + price[selected_product], 8'h24, //hien tien
                                  8'h20, 8'h20, 8'h20, //dau cach
                                  8'h4E, 8'h75, 8'h6D, 8'h3A, 8'h30 + product_count_ready[selected_product]}; //hien thi so luong
                end
                
                 else begin

                     lcd_line1 <= {8'h20, 8'h20, 8'h41, 8'h44, 8'h4D, 8'h49, 8'h4E,
                                   8'h20, 8'h4D, 8'h4F, 8'h44, 8'h45, 8'h20, 8'h20, 8'h20, 8'h20};
                     lcd_line2 <= {8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20,
                                   8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20};
                 
                    
                 end
            end
        end
    end

endmodule


