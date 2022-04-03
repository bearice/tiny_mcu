module led (
        input clk,
        input rst,

        input [7:0] r,
        input [7:0] g,
        input [7:0] b,

        output LED_R,
        output LED_G,
        output LED_B
    );

    pwm #(8) pwm_r (
            .clk (clk),
            .rst (rst),
            .threshold (r),
            .max (255),
            .pwm (LED_R)
        );

    pwm #(8) pwm_g (
            .clk (clk),
            .rst (rst),
            .threshold (g),
            .max (255),
            .pwm (LED_G)
        );

    pwm #(8) pwm_b (
            .clk (clk),
            .rst (rst),
            .threshold (b),
            .max (255),
            .pwm (LED_B)
        );

endmodule
