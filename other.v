module clock_divider#(parameter n=22) (
    input clk,
    input rst,
    output clk_div  
    );
    // parameter n = 17;
    reg [n-1:0] num;
    wire [n-1:0] next_num;
    always @(posedge clk) begin
        if(rst)
            num <= 0;
        else
            num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule
