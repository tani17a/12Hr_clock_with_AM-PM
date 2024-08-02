module top_module(
    input clk,
    input reset,
    input ena,
    output reg pm,
    output reg[7:0] hh,
    output reg [7:0] mm,
    output reg [7:0] ss);

    wire [3:0] hr;
    reg toggle_pm;

    // Clock, Minute, and Second Counters
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pm <= 0;
            toggle_pm <= 0;
        end else begin
            if (hh[7:4] == 4'h1 && hh[3:0] == 4'd1 && mm[7:4] == 4'd5 && mm[3:0] == 4'd9 && ss[7:4] == 4'd5 && ss[3:0] == 4'd9) begin
                toggle_pm <= ~toggle_pm;
            end
            pm <= toggle_pm;
        end
    end

    decade_counter nin(clk, reset, ena, ss[3:0]);
    six_counter fiv(clk, reset, ena & (ss[3:0] == 4'd9), ss[7:4]);
    
    decade_counter nine(clk, reset, ena & (ss[3:0] == 4'd9 & ss[7:4] == 4'd5), mm[3:0]);
    six_counter five(clk, reset, ena & (mm[3:0] == 4'd9) & (ss[3:0] == 4'd9 & ss[7:4] == 4'd5), mm[7:4]);
    
    hrs_counter hhr(clk, reset, ena & (mm[7:4] == 4'd5 & mm[3:0] == 4'd9 & ss[7:4] == 4'd5 & ss[3:0] == 4'd9), hr);
    bcd_converter bcd(hr, hh[7:4], hh[3:0]);

endmodule

module bcd_converter(input [3:0] d,
                     output reg [3:0] o1,
                     output reg [3:0] o2);
    always @(*) begin
        if (d < 4'd10) begin
            o1 = 4'd0;
            o2 = d;
        end else begin
            o1 = 4'h1;
            case (d)
                4'd10: o2 = 4'd0;
                4'd11: o2 = 4'd1;
                default: o2 = 4'd2;
            endcase
        end
    end
endmodule

module six_counter(
    input clk,
    input reset,
    input ena,
    output [3:0] q
    );
    wire allre;
    
    tf ff1(ena, clk, allre, q[0]);
    tf ff2(q[0] & ena, clk, allre, q[1]);
    tf ff3(q[0] & q[1] & ena, clk, allre, q[2]);
    tf ff4(q[0] & q[1] & q[2] & ena, clk, allre, q[3]);
    assign allre = reset | (q[0] & q[2] & ena);
endmodule

module decade_counter(
    input clk,
    input reset,
    input ena,
    output reg [3:0] q
   );
    wire allre;
    
    tf ff1(ena, clk, allre, q[0]);
    tf ff2(q[0] & ena, clk, allre, q[1]);
    tf ff3(q[0] & q[1] & ena, clk, allre, q[2]);
    tf ff4(q[0] & q[1] & q[2] & ena, clk, allre, q[3]);
    assign allre = reset | (q[0] & q[3] & ena);
endmodule

module tf(input t, clk, reset,
          output reg q);
    always @(posedge clk or posedge reset) begin
        if (reset) q <= 1'b0;
        else if (t) q <= ~q;
    end
endmodule

module hrs_counter(
    input clk,
    input reset,
    input ena,
    output [3:0] q
   );
    wire allre;
    wire q0, q1, q2, q3;
    
    tf1 ff1(ena, clk, allre, reset, q0);
    tf ff2(q0 & ena, clk, allre | reset, q1);
    tf2 ff3(q0 & q1 & ena, clk, allre, reset, q2);
    tf2 ff4(q0 & q1 & q2 & ena, clk, allre, reset, q3);
    
    assign allre = (q3 & q2 & ena);
    assign q = {q3, q2, q1, q0};
endmodule

module tf1(input t, clk, reset, re,
           output reg q);
    always @(posedge clk or posedge reset) begin
        if (reset) q <= 1'b1;
        else if (re) q <= 1'b0;
        else if (t) q <= ~q;
    end
endmodule

module tf2(input t, clk, reset, re,
           output reg q);
    always @(posedge clk or posedge reset) begin
        if (reset) q <= 1'b0;
        else if (re) q <= 1'b1;
        else if (t) q <= ~q;
    end
endmodule

