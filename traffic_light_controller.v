`timescale 1s / 1ms

module traffic_light_controller #(
    parameter GREEN_TIME   = 3'd6,
    parameter YELLOW_TIME  = 3'd1,
    parameter ALL_RED_TIME = 3'd1
)(
    input  wire        clk,
    input  wire        rst,
    output reg  [2:0]  light_A, // East-West:   [2]=Red, [1]=Yellow, [0]=Green
    output reg  [2:0]  light_B  // North-South: [2]=Red, [1]=Yellow, [0]=Green
);

    // Light encoding definitions: 3'b[Red][Yellow][Green]
    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;

    // FSM State Encoding
    localparam [2:0] 
        S0_EW_GREEN  = 3'b000,
        S1_EW_YELLOW = 3'b001,
        S2_ALL_RED_1 = 3'b010,
        S3_NS_GREEN  = 3'b011,
        S4_NS_YELLOW = 3'b100,
        S5_ALL_RED_2 = 3'b101;

    reg [2:0] state;
    reg [2:0] timer;

    // State Transition & Timer Sequential Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0_EW_GREEN;
            timer <= 3'd1;
        end else begin
            case (state)
                S0_EW_GREEN: begin
                    if (timer < GREEN_TIME) begin
                        timer <= timer + 1'b1;
                    end else begin
                        state <= S1_EW_YELLOW;
                        timer <= 3'd1;
                    end
                end

                S1_EW_YELLOW: begin
                    if (timer < YELLOW_TIME) begin
                        timer <= timer + 1'b1;
                    end else begin
                        state <= S2_ALL_RED_1;
                        timer <= 3'd1;
                    end
                end

                S2_ALL_RED_1: begin
                    if (timer < ALL_RED_TIME) begin
                        timer <= timer + 1'b1;
                    end else begin
                        state <= S3_NS_GREEN;
                        timer <= 3'd1;
                    end
                end

                S3_NS_GREEN: begin
                    if (timer < GREEN_TIME) begin
                        timer <= timer + 1'b1;
                    end else begin
                        state <= S4_NS_YELLOW;
                        timer <= 3'd1;
                    end
                end

                S4_NS_YELLOW: begin
                    if (timer < YELLOW_TIME) begin
                        timer <= timer + 1'b1;
                    end else begin
                        state <= S5_ALL_RED_2;
                        timer <= 3'd1;
                    end
                end

                S5_ALL_RED_2: begin
                    if (timer < ALL_RED_TIME) begin
                        timer <= timer + 1'b1;
                    end else begin
                        state <= S0_EW_GREEN;
                        timer <= 3'd1;
                    end
                end

                default: begin
                    state <= S0_EW_GREEN;
                    timer <= 3'd1;
                end
            endcase
        end
    end

    // Combinational Output Decoding Logic
    always @(*) begin
        case (state)
            S0_EW_GREEN:  begin light_A = GREEN;  light_B = RED;    end
            S1_EW_YELLOW: begin light_A = YELLOW; light_B = RED;    end
            S2_ALL_RED_1: begin light_A = RED;    light_B = RED;    end
            S3_NS_GREEN:  begin light_A = RED;    light_B = GREEN;  end
            S4_NS_YELLOW: begin light_A = RED;    light_B = YELLOW; end
            S5_ALL_RED_2: begin light_A = RED;    light_B = RED;    end
            default:      begin light_A = RED;    light_B = RED;    end
        endcase
    end

endmodule
