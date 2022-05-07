`timescale 1ns / 1ns

`define RAM_CAPACITY_4M			17
`define RAM_CAPACITY_1M			15

`define RAM_CAPACITY			`RAM_CAPACITY_4M
`define SAMPLE_RUN_COUNT_BITS	`RAM_CAPACITY - 2

module logiana
(
	CLK24,
	OSC_CLK,
	EXT_CLK,
	PROBE,
	
	H_nRD,
	H_nWR,
	H_DATA,
	H_MODE,
	
	ST_STP,
	RUNNING,
	
	RAM_ADDR,
	RAM_DATA,
	RAM_nCE3,
	RAM_nOE,
	RAM_nGW,
	RAM_nADSC,
	RAM_CLK,
	
	USER,
	
	CN1_40,
	CN3_1,
	CN3_2,
	CN3_29,
	CN3_30,
	CN3_31,
	
	PC0_P60
);

localparam [15:0] PROBE_SPEED_25_0_MHZ = (4 / 2) - 1;
localparam [15:0] PROBE_SPEED_16_6_MHZ = (6 / 2) - 1;
localparam [15:0] PROBE_SPEED_12_5_MHZ = (8 / 2) - 1;
localparam [15:0] PROBE_SPEED_10_0_MHZ = (10 / 2) - 1;
localparam [15:0] PROBE_SPEED_8_3_MHZ =  (12 / 2) - 1;
localparam [15:0] PROBE_SPEED_5_0_MHZ =  (20 / 2) - 1;
localparam [15:0] PROBE_SPEED_3_8_MHZ =  (26 / 2) - 1;
localparam [15:0] PROBE_SPEED_2_0_MHZ =  (50 / 2) - 1;
localparam [15:0] PROBE_SPEED_1_0_MHZ =  (100 / 2) - 1;
localparam [15:0] PROBE_SPEED_500_KHZ =  (200 / 2) - 1;
localparam [15:0] PROBE_SPEED_100_KHZ =  (1000 / 2) - 1;
localparam [15:0] PROBE_SPEED_10_KHZ =   (10000 / 2) - 1;
localparam [15:0] PROBE_SPEED_1_KHZ =    (100000 / 2) - 1;

localparam [1:0] TRIGGER_TYPE_TOP		= 0;
localparam [1:0] TRIGGER_TYPE_CENTER	= 1;
localparam [1:0] TRIGGER_TYPE_LAST		= 2;

localparam [1:0] TRIGGER_COND_POSEDGE = 0;
localparam [1:0] TRIGGER_COND_NEGEDGE = 1;
localparam [1:0] TRIGGER_COND_HIGLEVEL = 2;
localparam [1:0] TRIGGER_COND_LOWLEVEL = 3;

input wire CLK24;
input wire OSC_CLK;
input wire EXT_CLK;
input wire [31:0] PROBE;

input wire H_nRD;
input wire H_nWR;
input wire H_MODE;
input wire ST_STP;
inout wire [7:0] H_DATA;
output wire RUNNING;

output wire [16:0] RAM_ADDR;
output wire RAM_nCE3;
output wire RAM_nOE;
output wire RAM_nGW;
output wire RAM_nADSC;
output wire RAM_CLK;
inout wire [31:0] RAM_DATA;

input wire [7:0] USER;
input wire CN3_1, CN3_2, CN3_29, CN3_30, CN3_31;
input wire CN1_40;

input wire PC0_P60;

reg CLK_PES = 0;
reg [15:0] CLK_CNT = 0;
wire CLK_IN;

reg [17:0] RAM_ADDR_IN;
reg RAM_WRAPPED;

reg TRG;
reg TRG_UP;
reg TRG_DOWN;
wire TRG_LINE;
wire TRG_HDL;

reg st_stp_a;
wire nSAMPLING;
wire READING;

reg [1:0] STATE;
reg [14:0] RUN_CNT;

reg [7:0] H_DATA_OUT;
reg [1:0] H_RD_CNT;

reg [3:0] P_CLK_SEL = 4'b0000;
reg [3:0] P_TRG_SEL = 4'b0000;
reg [1:0] P_TRG_TYPE;
reg [1:0] P_TRG_COND;

wire SEL_CLK = (P_CLK_SEL == 4'd0 ? OSC_CLK : (P_CLK_SEL == 4'd15 ? EXT_CLK : CLK_PES));

assign nSAMPLING = (STATE[0] | STATE[1]);
assign READING = (STATE[0] & STATE[1]);

assign CLK_IN = (READING == 1 ? H_RD_CNT[1] : SEL_CLK);

assign H_DATA = (H_nRD == 0 ? H_DATA_OUT : 8'bzzzzzzzz);
assign RUNNING = (H_MODE == 0 ? READING : RAM_WRAPPED);

assign RAM_ADDR[1:0] = 2'b00;
assign RAM_ADDR[16:2] = RAM_ADDR_IN[16:2];
assign RAM_DATA = (nSAMPLING == 1 ? {32{1'bz}} : PROBE);
assign RAM_CLK = CLK_IN;
assign RAM_nCE3 = ~st_stp_a;
assign RAM_nGW = nSAMPLING;
assign RAM_nOE = ~nSAMPLING;
assign RAM_nADSC = (RAM_ADDR_IN[1] | RAM_ADDR_IN[0]);

assign TRG_LINE = select_trigger_line({TRG_HDL, PROBE[14:0]}, P_TRG_SEL);
assign TRG_HDL = PROBE[15];

// generate sampling clk
always @(posedge OSC_CLK)
begin
	if (CLK_CNT == 0) begin
		CLK_PES <= ~CLK_PES;
		CLK_CNT <= select_sample_rate(P_CLK_SEL);
	end
	else begin
		CLK_CNT <= CLK_CNT - 1'b1;
	end
end

// align ST_STP signal to CLK_IN
always @(negedge CLK_IN or negedge ST_STP)
begin
	if (ST_STP == 0) begin
		st_stp_a <= 0;
	end
	else begin
		st_stp_a <= 1;
	end
end

always @(posedge H_nWR)
begin
	if (H_nRD == 1) begin
		if (H_MODE == 0) begin
			P_CLK_SEL <= H_DATA[7:4];
			P_TRG_TYPE <= H_DATA[1:0];
		end
		else begin
			P_TRG_COND <= H_DATA[7:6];
			P_TRG_SEL <= H_DATA[5:2];
		end
	end
end

always @(negedge H_nRD)
begin
	if (H_nWR == 1) begin
		H_DATA_OUT <= get_host_read_data(H_RD_CNT, RAM_DATA);
	end
end

always @(posedge H_nRD or negedge st_stp_a)
begin
	if (st_stp_a == 0) begin
		H_RD_CNT <= 2'b10;
	end
	else begin
		if (H_nWR == 1) begin
			H_RD_CNT <= H_RD_CNT + 1'b1;
		end
	end
end

// ram addressing
always @(negedge CLK_IN or negedge st_stp_a)
begin
	if (st_stp_a == 0) begin
		RAM_ADDR_IN <= 0;
		RAM_WRAPPED <= 0;
	end
	else begin
        RAM_ADDR_IN <= RAM_ADDR_IN + 1'b1;

		if (RAM_ADDR_IN[`RAM_CAPACITY] == 1'b1)
			RAM_WRAPPED <= 1;
	end
end

always @(posedge CLK_IN or negedge st_stp_a)
begin
    if (st_stp_a == 0) begin
        RUN_CNT <= 0;
    end
    else begin
        if (TRG == 1 && nSAMPLING == 0 && RAM_ADDR_IN[1:0] == 2'b11) begin
            RUN_CNT <= RUN_CNT + 1'b1;
        end
    end
end

always @(negedge CLK_IN or negedge st_stp_a)
begin
	if (st_stp_a == 0) begin
		STATE <= 0;
	end
	else begin
		if (TRG == 1) begin
			if (nSAMPLING == 0) begin
				if (RAM_ADDR_IN[1:0] == 2'b11) begin
					if (((P_TRG_TYPE == TRIGGER_TYPE_TOP)   && (RUN_CNT[`SAMPLE_RUN_COUNT_BITS - 1 : 3] == {`SAMPLE_RUN_COUNT_BITS - 3{1'b1}})) ||
						((P_TRG_TYPE == TRIGGER_TYPE_CENTER) && (RUN_CNT[`SAMPLE_RUN_COUNT_BITS - 1]    == 1'b1)) ||
						((P_TRG_TYPE == TRIGGER_TYPE_LAST)   && (RUN_CNT[3]      						== 1'b1))) begin
						STATE <= 1;
					end
				end
			end
			else if (READING == 0) begin
				// for setting up RAM_ADDR and RAM_nADSC before reading start
                STATE <= 2'b11;
			end
		end
	end
end

// trigger control
always @(posedge CLK_IN or negedge st_stp_a)
begin
	if (st_stp_a == 0) begin
		TRG <= 0;
	end
	else begin
		if (((P_TRG_COND == TRIGGER_COND_POSEDGE) && (TRG_UP   == 1'b1)) ||
			 ((P_TRG_COND == TRIGGER_COND_NEGEDGE) && (TRG_DOWN == 1'b1)) ||
			 ((P_TRG_COND == TRIGGER_COND_HIGLEVEL) && (TRG_LINE == 1'b1)) ||
			 ((P_TRG_COND == TRIGGER_COND_LOWLEVEL) && (TRG_LINE == 1'b0))) begin
				TRG <= 1;
		end
	end
end

always @(posedge TRG_LINE or negedge ST_STP)
begin
	if (ST_STP == 0) begin
		TRG_UP <= 0;
	end
	else begin
		TRG_UP <= 1;
	end
end

always @(negedge TRG_LINE or negedge ST_STP)
begin
	if (ST_STP == 0) begin
		TRG_DOWN <= 0;
	end
	else begin
		TRG_DOWN <= 1;
	end
end

function [15:0] select_sample_rate;
	input [3:0] clk_sel;
	begin
		case (clk_sel)
			4'd2: select_sample_rate = PROBE_SPEED_25_0_MHZ;
			4'd3: select_sample_rate = PROBE_SPEED_16_6_MHZ;
			4'd4: select_sample_rate = PROBE_SPEED_12_5_MHZ;
			4'd5: select_sample_rate = PROBE_SPEED_10_0_MHZ;
			4'd6: select_sample_rate = PROBE_SPEED_8_3_MHZ;
			4'd7: select_sample_rate = PROBE_SPEED_5_0_MHZ;
			4'd8: select_sample_rate = PROBE_SPEED_3_8_MHZ;
			4'd9: select_sample_rate = PROBE_SPEED_2_0_MHZ;
			4'd10: select_sample_rate = PROBE_SPEED_1_0_MHZ;
			4'd11: select_sample_rate = PROBE_SPEED_500_KHZ;
			4'd12: select_sample_rate = PROBE_SPEED_100_KHZ;
			4'd13: select_sample_rate = PROBE_SPEED_10_KHZ;
			4'd14: select_sample_rate = PROBE_SPEED_1_KHZ;
			default: select_sample_rate = 0;	// 50MHz
		endcase
	end
endfunction

function select_trigger_line;
	input [15:0] trigger_source;
	input [3:0] sel;
	begin
		select_trigger_line = trigger_source[sel];
	end
endfunction

function [7:0] get_host_read_data;
	input [1:0] index;
	input [31:0] ram_data;
	begin
		case (index)
			2: get_host_read_data = ram_data[7:0];
			3: get_host_read_data = ram_data[15:8];
			0: get_host_read_data = ram_data[23:16];
			1: get_host_read_data = ram_data[31:24];
		endcase		
	end
endfunction

endmodule
