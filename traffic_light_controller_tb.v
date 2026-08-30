`timescale 1s / 1ms

module traffic_light_controller_tb;

    reg        clk;
    reg        rst;
    wire [2:0] light_A;
    wire [2:0] light_B;

    // Instantiate Unit Under Test (UUT) with named port connections
    traffic_light_controller #(
        .GREEN_TIME(3'd6),
        .YELLOW_TIME(3'd1),
        .ALL_RED_TIME(3'd1)
    ) uut (
        .clk(clk),
        .rst(rst),
        .light_A(light_A),
        .light_B(light_B)
    );

    // Clock Generator: 1 Hz clock (Period = 1s, #0.5s toggle)
    initial begin
        clk = 1'b0;
        forever #0.5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Initialize inputs
        rst = 1'b1;
        #2;

        // Release reset to start FSM
        rst = 1'b0;

        // Run simulation through 2 complete 16-second FSM cycles
        #34;

        $display("Simulation completed successfully.");
        $finish;
    end

    // VCD Waveform Generation for GTKWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, traffic_light_controller_tb);
    end

endmodule
