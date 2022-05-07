`timescale 1ns / 1ns

module logiana_test;

	// Inputs
	reg CLK24;
	reg OSC_CLK;
	reg EXT_CLK;
	reg [31:0] PROBE;
	
	reg H_nRD;
	reg H_nWR;
	reg H_MODE;
	reg ST_STP;

	// Outputs
	wire [16:0] RAM_ADDR;
	wire RAM_nCE3;
	wire RAM_nOE;
	wire RAM_nGW;
	wire RAM_nADSC;
	wire RAM_CLK;
	wire RUNNING;
	wire [7:0] USER;
    wire CN1_40;
	
	// inout
	reg [31:0] RAM_DATA_REG;
   wire [31:0] RAM_DATA;
	assign RAM_DATA = (RAM_nGW == 0 ? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : RAM_DATA_REG);
	
	reg [7:0] H_DATA_REG;
	wire [7:0] H_DATA;
	assign H_DATA = (H_nWR == 0 ? H_DATA_REG : 8'bzzzzzzzz);

//	wire [14:0] DEBUG;

	// Instantiate the Unit Under Test (UUT)
	logiana uut (
		.USER(USER),
        .CN1_40(CN1_40),
		.OSC_CLK(OSC_CLK), 
		.EXT_CLK(EXT_CLK), 
		.CLK24(CLK24),
		.PROBE(PROBE),
		.H_nRD(H_nRD),
		.H_nWR(H_nWR),
		.H_MODE(H_MODE),
		.H_DATA(H_DATA),
		.ST_STP(ST_STP), 
		.RAM_ADDR(RAM_ADDR),
		.RAM_DATA(RAM_DATA),
		.RAM_nCE3(RAM_nCE3), 
		.RAM_nOE(RAM_nOE), 
		.RAM_nGW(RAM_nGW), 
		.RAM_nADSC(RAM_nADSC), 
		.RAM_CLK(RAM_CLK),
		.RUNNING(RUNNING)
	);
	
	always #5 OSC_CLK = ~OSC_CLK;
	always #20 CLK24 = ~CLK24;

	initial begin
		// Initialize Inputs
		OSC_CLK = 0;
		EXT_CLK = 0;
		CLK24 = 0;
		ST_STP = 0;
		H_nWR = 1;
		H_nRD = 1;
		H_MODE = 0;
		PROBE = 0;

		// Wait for global reset to finish
		#100;
		ST_STP = 0;
		
		// Add stimulus here
		#50
		H_MODE = 0;
		H_DATA_REG = 8'h12;	// sampling rate 50MHz, LAST
		#10;
		H_nWR = 0;
		#10;
		H_nWR = 1;
		#10;

		
		#50;
		H_MODE = 1;		
		H_DATA_REG = 8'h00;	// pos-edge trigger on probe[0]
		#10;
		H_nWR = 0;
		#10;
		H_nWR = 1;

		#97;
		H_MODE = 0;		
		ST_STP = 1;

		#200;
		PROBE[0] = 1;
		
		#800;
		H_MODE = 1;
		#20;
		
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;

		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;
		H_nRD = 0;
		#20;
		H_nRD = 1;
		#20;


		
	end
      
endmodule

