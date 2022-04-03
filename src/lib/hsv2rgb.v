module hsv2rgb (
        input [7:0] h,
        input [7:0] s,
        input [7:0] v,
        output [7:0] r,
        output [7:0] g,
        output [7:0] b
    );

    wire [7:0] region = h / 43;
    wire [7:0] remainder = (h - (region *43)) * 6;
    wire [7:0] p = (v * (255 - s)) >> 8;
    wire [7:0] q = (v * (255 - ((s * remainder) >> 8))) >> 8;
    wire [7:0] t = (v * (255 - ((s * (255 - remainder)) >> 8))) >> 8;

    reg [23:0] out;
    assign {r,g,b} = out;

    always @* begin
        if (s == 0) begin
            out = {v,v,v};
        end
        else begin
            case (region)
                0: begin
                    out = {v,t,p};
                end
                1: begin
                    out = {q,v,p};
                end
                2: begin
                    out = {p,v,t};
                end
                3: begin
                    out = {p,q,v};
                end
                4: begin
                    out = {t,p,v};
                end
                default: begin
                    out = {v,p,q};
                end
            endcase
        end
    end
endmodule
