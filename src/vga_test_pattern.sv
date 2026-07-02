`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 01:12:04 AM
// Design Name: 
// Module Name: vga_test_pattern
// Project Name: 
// Target Devices: Nexys A7-100T
// Tool Versions: 
// Description: Wrapper top-level module that instantiates vga_controller and 
//              generates a colorful test pattern on the screen.
//              Outputs are mapped to the 12-bit physical VGA port of the Nexys A7.
// 
// Dependencies: vga_controller.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_test_pattern(
    input  logic       clk_100mhz, // Board clock (100 MHz)
    input  logic       reset_n,    // Active-low reset (physical CPU_RESETN button)
    output logic       hsync,      // VGA horizontal sync
    output logic       vsync,      // VGA vertical sync
    output logic [3:0] vga_r,      // 4-bit Red output
    output logic [3:0] vga_g,      // 4-bit Green output
    output logic [3:0] vga_b       // 4-bit Blue output
);

    // Internal active-high reset for standard FPGA logic
    logic       reset;
    assign reset = ~reset_n;

    // Internal signals from the VGA controller
    logic       video_on;
    logic [9:0] x;
    logic [9:0] y;

    // Instantiate the VGA timing controller
    vga_controller u_vga_controller (
        .clk_100mhz (clk_100mhz),
        .reset      (reset),
        .hsync      (hsync),
        .vsync      (vsync),
        .video_on   (video_on),
        .x          (x),
        .y          (y)
    );

    // Generate the test pattern
    // We will show 3 horizontal gradient bands:
    // - Top third (y < 160): Red gradient
    // - Middle third (160 <= y < 320): Green gradient
    // - Bottom third (320 <= y < 480): Blue gradient
    //
    // Since x ranges from 0 to 639, we divide by 40 to get 16 steps (0 to 15) for our 4-bit color depth:
    // 640 / 16 = 40.
    //
    // Additionally, we will draw a 2-pixel wide white border around the active display area
    // to verify that the alignment and dimensions are perfectly correct on the screen.
    
    always_comb begin
        // Default to black (e.g., during blanking intervals when video_on is low)
        vga_r = 4'h0;
        vga_g = 4'h0;
        vga_b = 4'h0;

        if (video_on) begin
            // 1. Draw a white border around the screen boundary
            if (x < 2 || x > 637 || y < 2 || y > 477) begin
                vga_r = 4'hF;
                vga_g = 4'hF;
                vga_b = 4'hF;
            end
            // 2. Otherwise, draw the color gradients
            else begin
                if (y < 160) begin
                    // Red band: gradient scales with x (x / 40)
                    vga_r = x[9:0] / 40;
                    vga_g = 4'h0;
                    vga_b = 4'h0;
                end
                else if (y < 320) begin
                    // Green band: gradient scales with x (x / 40)
                    vga_r = 4'h0;
                    vga_g = x[9:0] / 40;
                    vga_b = 4'h0;
                end
                else begin
                    // Blue band: gradient scales with x (x / 40)
                    vga_r = 4'h0;
                    vga_g = 4'h0;
                    vga_b = x[9:0] / 40;
                end
            end
        end
    end

endmodule
