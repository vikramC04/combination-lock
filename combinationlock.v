module combinationlock(CLOCK_50, SW, KEY, HEX5);
   input CLOCK_50;
	input [9:6] SW;
	input [3:0] KEY;
	output [0:6] HEX5;
	
	assign clock = CLOCK_50;
	assign X = SW[9:6];
	assign enter = KEY[0];
	assign change = KEY[1];
	assign resetn = KEY[2];
	
	wire clock, enter, change, resetn;
   wire alarm, new, open;
	wire [3:0] X;
	wire [3:0] combination;
	wire correct;
	wire enter_pulse, change_pulse;
	wire [0:6] leds;

	 
	register storage(X, clock, new, resetn, combination);
	compare test(X, combination, correct);

   inputConditioning condition_enter(clock, enter, enter_pulse);
   inputConditioning condition_change(clock, change, change_pulse);
    
   moorestatemachine combinationlock(correct, clock, enter_pulse, change_pulse, resetn, alarm, new, open);
	 
	hex7seg display(alarm, new, open, leds);
	
	assign HEX5 = leds;

endmodule

//4-Bit Register with Enable
module register(D, clock, enable, resetn, Q);
	input [3:0] D;
	input clock, resetn, enable;
	output reg [3:0] Q;
	always @(posedge clock, negedge resetn)
	if (resetn == 0)
		Q <= 4'b0110;
	else if (enable == 1)
		Q <= D;
endmodule

//Comparator
module compare(A, B, s);
	input [3:0] A, B;
	output reg s;
	
	always @(A, B)
	begin
		if (A == B)
			s = 1;
		else
			s = 0;
	end
endmodule

//Input Conditioning
module inputConditioning(Clock, a, a_pulse);
	input Clock, a;
	output a_pulse;
	reg [2:1] y, Y;
	parameter [2:1] A = 2'b00, B = 2'b01, C = 2'b10;

	always @(a, y)
		case (y)
			A: if (a) 	Y = B;
				else 		Y = A;
			B: if (a) 	Y = C;
				else 		Y = A;
			C: if (a) 	Y = C;
				else 		Y = A;
			default: 	Y = 2'bxx;
	endcase

	always @(posedge Clock)
		y <= Y;
		
	assign a_pulse = (y == B);
	
endmodule


//State Machine
module moorestatemachine(correct, clock, enter, change, resetn, alarm, new, open);

	input clock, resetn, enter, change, correct;
	output alarm, new, open;
	
	reg[2:0] y, Y;
	
	parameter Default = 3'b000, Open = 3'b001, Fail = 3'b010, Alarm = 3'b011, Change = 3'b100;  
	
	always @(y, enter, change, correct)
	begin
		case(y)
			Default:
				if (correct == 1 & enter == 1 & change == 0) Y = Open;
				else if (correct == 1 & enter == 0 & change == 1) Y = Change;
				else if (correct == 0 & enter == 1 & change == 0) Y = Fail;
				else if (correct == 0 & enter == 0 & change == 1) Y = Fail;
				else Y = Default;
			Open:
				if (enter == 1 & change == 0) Y = Default;
				else Y = Open;
			Fail:
				if (correct == 1 & enter == 1 & change == 0) Y = Open;
				else if (correct == 1 & enter == 0 & change == 1) Y = Change;
				else if (correct == 0 & enter == 1 & change == 0) Y = Alarm;
				else if (correct == 0 & enter == 0 & change == 1) Y = Alarm;
				else Y = Fail;
			Alarm: 
				Y = Alarm;
			Change:
				if (enter == 1 | change == 1) Y = Default;
				else Y = Change;
			default: Y = 3'bxxx;
		endcase
	end
	
	always @(posedge clock, negedge resetn)
	begin
		if (resetn == 0)
			y <= Default;
		else 
			y <= Y;
	end

	assign open = (y == Open);
	assign new = (y == Change);
	assign alarm = (y == Alarm);
endmodule

//Display
module hex7seg(alarm, new, open, leds);
	input alarm, new, open;
	reg [1:0] hex;
	output reg [0:6] leds;
	
	always @(alarm, new, open)
	begin
		if (alarm == 1)
			hex <= 2'b01;
		else if (open == 1)
			hex <= 2'b11;
		else if (new == 1)
			hex <= 2'b10;
		else
			hex <= 2'b00;
		
		case(hex)
			0: leds = 7'b1111110; //-
			1: leds = 7'b0001000; //alarm
			2: leds = 7'b1101010; //new
			3: leds = 7'b0000001; //open
		endcase
	end
	
endmodule