`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 06:14:38 PM
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
    input  logic       clk_100mhz, // Board clock (100 MHz)
    input  logic       reset,      // Active-high reset
    output logic       hsync,      // Horizontal sync pulse (active-low)
    output logic       vsync,      // Vertical sync pulse (active-low)
    output logic       video_on,   // High when in active visible screen area
    output logic [9:0] x,          // Current horizontal pixel coordinate (0-639)
    output logic [9:0] y           // Current vertical pixel coordinate (0-479)
);

    // VGA 640x480 @ 60Hz timing parameters
    localparam H_ACTIVE      = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC        = 96;
    localparam H_BACK_PORCH  = 48;
    localparam H_TOTAL       = H_ACTIVE + H_FRONT_PORCH + H_SYNC + H_BACK_PORCH; // 800

    localparam V_ACTIVE      = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC        = 2;
    localparam V_BACK_PORCH  = 33;
    localparam V_TOTAL       = V_ACTIVE + V_FRONT_PORCH + V_SYNC + V_BACK_PORCH; // 525

    // Clock division: 100 MHz -> 25 MHz
    // We create a pixel clock enable pulse instead of generating a gated clock.
    // This is a standard FPGA design practice to avoid clock skew and timing issues.
    logic [1:0] clk_div;
    logic       pix_en;

    always_ff @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            clk_div <= 2'b00;
        end else begin
            clk_div <= clk_div + 1'b1;
        end
    end
    
    // pix_en is HIGH once every 4 board clock cycles (25 MHz rate)
    assign pix_en = (clk_div == 2'b11);

    // Timing counters
    logic [9:0] h_count;
    logic [9:0] v_count;

    // Horizontal Counter (sweeps left to right)
    always_ff @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            h_count <= 10'd0;
        end else if (pix_en) begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;
            end else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    // Vertical Counter (sweeps top to bottom, increments when a full line completes)
    always_ff @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            v_count <= 10'd0;
        end else if (pix_en && (h_count == H_TOTAL - 1)) begin
            if (v_count == V_TOTAL - 1) begin
                v_count <= 10'd0;
            end else begin
                v_count <= v_count + 1'b1;
            end
        end
    end

    // Sync Signals (Active-Low)
    // hsync is LOW during the sync pulse interval [656, 751]
    assign hsync = ~((h_count >= (H_ACTIVE + H_FRONT_PORCH)) && 
                     (h_count < (H_ACTIVE + H_FRONT_PORCH + H_SYNC)));

    // vsync is LOW during the sync pulse interval [490, 491]
    assign vsync = ~((v_count >= (V_ACTIVE + V_FRONT_PORCH)) && 
                     (v_count < (V_ACTIVE + V_FRONT_PORCH + V_SYNC)));

    // video_on is HIGH only when the beam is within the visible 640x480 screen area
    assign video_on = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

    // Outputs coordinates (only valid when video_on is HIGH)
    assign x = h_count;
    assign y = v_count;

endmodule

