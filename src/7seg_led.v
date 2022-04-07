module SevenSegLed(
        input clk,
        input [31:0] data,
        output reg LED_DATA,LED_SCK,LED_RCK
    );

    reg [3:0] shift;
    reg [2:0] digit;

    wire [3:0] d = data >> digit*4;
    wire [7:0] c = led_code(d);
    wire [7:0] a = 8'h80 >> digit;
    reg [15:0] out;
    reg [1:0] state;
    localparam ST_DATA = 0;
    localparam ST_RCK = 2;
    localparam ST_SCK = 3;
    always @(posedge clk) begin
        case (state)
            ST_DATA: begin
                LED_DATA <= out[shift];
                LED_SCK <= 1'b1;
                LED_RCK <= 1'b0;
                state <= ST_SCK;
            end
            ST_SCK: begin
                LED_SCK <= 1'b0;
                if (shift == 0) begin
                    shift <= 15;
                    state <= ST_RCK;
                end
                else begin
                    shift <= shift - 1;
                    state <= ST_DATA;
                end
            end
            ST_RCK: begin
                LED_RCK <= 1'b1;
                digit <= digit + 1;
                out <= {a,~c};
                state <= ST_DATA;
            end
        endcase
    end

    function [7:0] led_code;
        input [3:0] in;
        case (in)
            4'h0: led_code = 8'b00111111;
            4'h1: led_code = 8'b00000110;
            4'h2: led_code = 8'b01011011;
            4'h3: led_code = 8'b01001111;
            4'h4: led_code = 8'b01100110;
            4'h5: led_code = 8'b01101101;
            4'h6: led_code = 8'b01111101;
            4'h7: led_code = 8'b00000111;
            4'h8: led_code = 8'b01111111;
            4'h9: led_code = 8'b01101111;
            4'ha: led_code = 8'b01110111;
            4'hb: led_code = 8'b01111100;
            4'hc: led_code = 8'b00111001;
            4'hd: led_code = 8'b01011110;
            4'he: led_code = 8'b01111001;
            4'hf: led_code = 8'b01110001;
        endcase
    endfunction
endmodule


