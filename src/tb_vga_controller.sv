`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 07:39:14 PM
// Design Name: 
// Module Name: tb_vga_controller
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


module tb_vga_controller;

    // 1. Declare signals to connect to the Unit Under Test (UUT)
    logic clk_100mhz;
    logic reset;
    
    logic hsync;
    logic vsync;
    logic video_on;
    logic [9:0] x;
    logic [9:0] y;

    // 2. Instantiate the Unit Under Test (UUT)
    vga_controller uut (
        .clk_100mhz (clk_100mhz),
        .reset      (reset),
        .hsync      (hsync),
        .vsync      (vsync),
        .video_on   (video_on),
        .x          (x),
        .y          (y)
    );

    // 3. Generate the 100 MHz clock signal
    // Using an initial block with 'forever' ensures the clock is explicitly
    // set to 0 every time the simulation is restarted, preventing X-state bugs.
    initial begin
        clk_100mhz = 0;
        forever #5 clk_100mhz = ~clk_100mhz;
    end

    // 4. Stimulus block
    initial begin
        // Explicitly set reset high at the start of every simulation run/restart
        reset = 1;

        // Wait 100 ns while reset is held high
        #100;
        reset = 0; // Release reset to start the counters

        // Run simulation for 50 microseconds (50,000 ns)
        // One horizontal line takes 800 pixels * 4 clock cycles * 10 ns = 32,000 ns.
        // 50,000 ns lets us see a full horizontal line timing cycle and the start of the next.
        #50000;

        // End simulation
        $display("Simulation complete!");
        $finish;
    end

endmodule

