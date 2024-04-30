`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/30 17:25:21
// Design Name: 
// Module Name: BREATH_LED
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


module BREATH_LED #(
	parameter CLOCK_FRQ=50000000, //50M
	parameter PWM_FRQ=1000,//1K
	parameter BREATH_PERIOD=2,//2S
	parameter SET_COMPARE_FRQ=1000,//1K
	parameter PWM_COUNTER_MAX=CLOCK_FRQ/PWM_FRQ,
	parameter BREATH_COUNTER_MAX=CLOCK_FRQ*BREATH_PERIOD,
	parameter SET_COMPARE_COUNTER_MAX=CLOCK_FRQ/SET_COMPARE_FRQ,
	parameter COMPARE_VALUE_STEP=PWM_COUNTER_MAX/SET_COMPARE_FRQ
)
(
	input wire 		 CLK,
	input wire 		 RSTN,
	output wire [3:0] LED
);

reg [31:0] COUNTER_PWM;
reg [31:0] COUNTER_BREATH;
reg [31:0] COUNTER_COMPARE;
reg [31:0] COMPARE_VALUE;
reg PWM_PERIOD_CLK_VIEW;
reg BREATH_PERIOD_CLK_VIEW;
reg COMPARE_PERIOD_CLK_VIEW;
reg [3:0] LED_NUMBER;
reg LED_BREATH_VIEW;
reg BREATH_DIR;
reg [3:0] LED_REG;

assign LED = LED_REG;

//LED OUTPUT
always@(posedge CLK) begin
	if(RSTN == 0)LED_REG <= 0;
    case (LED_NUMBER)
        8'b000 : LED_REG[0] <= LED_BREATH_VIEW;
        8'b001 : LED_REG[1] <= LED_BREATH_VIEW;
        8'b010 : LED_REG[2] <= LED_BREATH_VIEW;
        8'b011 : LED_REG[3] <= LED_BREATH_VIEW;
        default: LED_REG[0] <= LED_BREATH_VIEW;
    endcase
end

//pwm
always @(posedge CLK or negedge RSTN)begin
	if(RSTN==0)begin
		COUNTER_PWM <= 0;
		PWM_PERIOD_CLK_VIEW <= 0;
	end
	else begin
		COUNTER_PWM<=COUNTER_PWM+1;
        if(COUNTER_PWM < COMPARE_VALUE) LED_BREATH_VIEW <= 1;
        else 							LED_BREATH_VIEW <= 0;
    
        if(COUNTER_PWM > PWM_COUNTER_MAX-1) begin
            COUNTER_PWM <= 0;
            PWM_PERIOD_CLK_VIEW <= ~PWM_PERIOD_CLK_VIEW;
        end
	end
end


reg [3:0] LED_NUMBER_STATE;
always @(posedge CLK or negedge RSTN)begin
	if(RSTN==0) begin
		LED_NUMBER <= 0;
		COUNTER_BREATH <= 0;
		BREATH_PERIOD_CLK_VIEW <= 0;
		BREATH_DIR <= 0;
		LED_NUMBER_STATE <= 0;
	end
	else begin
		COUNTER_BREATH <= COUNTER_BREATH+1;
		if(COUNTER_BREATH > BREATH_COUNTER_MAX-1)begin
			COUNTER_BREATH <= 0;
			BREATH_PERIOD_CLK_VIEW <= ~BREATH_PERIOD_CLK_VIEW;
			BREATH_DIR <= ~BREATH_DIR;
			if(BREATH_DIR == 1)begin
				case (LED_NUMBER_STATE)
					0: begin       LED_NUMBER_STATE <= 1; LED_NUMBER <= 0; end
					1: begin       LED_NUMBER_STATE <= 2; LED_NUMBER <= 1; end
					2: begin       LED_NUMBER_STATE <= 3; LED_NUMBER <= 2; end
					3: begin       LED_NUMBER_STATE <= 4; LED_NUMBER <= 3; end
					4: begin       LED_NUMBER_STATE <= 5; LED_NUMBER <= 2; end
					5: begin       LED_NUMBER_STATE <= 6; LED_NUMBER <= 1; end
					6: begin       LED_NUMBER_STATE <= 0; LED_NUMBER <= 0; end
					default: begin LED_NUMBER_STATE <= 0; LED_NUMBER <= 0; end
				endcase
			end
		end
	end
end

always@(posedge CLK or negedge RSTN) begin
	if(RSTN == 0)begin
		COUNTER_COMPARE <= 0;
		COMPARE_PERIOD_CLK_VIEW <= 0;
		COMPARE_VALUE <= 0;
	end
	else begin
		COUNTER_COMPARE <= COUNTER_COMPARE+1;
		if(COUNTER_COMPARE > SET_COMPARE_COUNTER_MAX-1)begin
			COUNTER_COMPARE <= 0;
			if(BREATH_DIR == 0)begin
				if(COMPARE_VALUE < PWM_COUNTER_MAX) COMPARE_VALUE <= COMPARE_VALUE + COMPARE_VALUE_STEP;
		    end
			else if(BREATH_DIR == 1)begin
				if(COMPARE_VALUE > 0) COMPARE_VALUE <= COMPARE_VALUE - COMPARE_VALUE_STEP;
			end
			COMPARE_PERIOD_CLK_VIEW <= ~COMPARE_PERIOD_CLK_VIEW;
		end
	end
end

endmodule
