USE WORK.ALL;

LIBRARY DATAPATH_LIB;
USE DATAPATH_LIB.all;
USE DATAPATH_LIB.package_MicroAssemblyCode.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_signed.all;
USE IEEE.std_logic_arith.all;

ENTITY VideoComposer_FSMD IS
	PORT (
		Clk          : IN  STD_LOGIC;
		Reset        : IN  STD_LOGIC;

		Start		 : IN STD_LOGIC;
		Ready		 : OUT STD_LOGIC;

		ROM_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DataIn	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);

		RAM_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		RAM_WE	: OUT STD_LOGIC;
		DataOut      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END VideoComposer_fsmd;

ARCHITECTURE behaviour OF videoComposer_FSMD IS

	CONSTANT ROM : Program_Type := (
		--| IE  | Dest | Src1 | Src2 | OpAlu | OpShift | OE  |
		  ('0',	R0,     Rx,     Rx,     OpXor,  OpPass, '0'), -- Reset_State
		  ('1',	R1,	Rx,	Rx,     OpXor,  OpPass,	'0'), -- S_Read_Red
		  ('1',	R2,	R1,	R1,     OpAnd,  OpPass,	'1'), -- S_WriteRed_ReadGreen
		  ('1',	R3,	R2,	R2,     OpAnd,  OpPass,	'1'), -- S_WriteGreen_ReadBlue

                  -- saturating Blue*4
                  ('0', R3,     R3,     R3,     OpAnd,  OpRotL, '0'), -- rotL Blue
                  ('0', R4,     R0,     R0,     OpInc,  OpPass, '0'), -- R4 = 1
                  ('0', R5,     R3,     R4,     OpAnd,  OpPass, '0'), -- R5 = Blue(7)
                  ('0', R3,     R3,     R3,     OpAnd,  OpRotL, '0'), -- rotL Blue
                  ('0', R6,     R3,     R4,     OpAnd,  OpPass, '0'), -- r6 = Blue(6)
                  ('0', R7,     R5,     R6,     OpOr ,  OpPass, '0'), -- r7 = Blue(6) or Blue(7)

                  ('0', R1,     R0,     R7,     OpSub,  OpPass, '0'), -- r1 = 0x00 - r7
                  ('0', R3,     R1,     R3,     OpOr ,  OpPass, '1'), -- Write: Blue = r1|r3   == (B[6] or B[7]) ? 0xFF : rotL2(Blue)

		  ('0',	Rx,	Rx,	Rx,     OpAnd,  OpPass,	'0'),  -- S_Idle
		  ('0',	Rx,	Rx,	Rx,     OpAnd,  OpPass,	'0'),  -- S_Idle
		  ('0',	Rx,	Rx,	Rx,     OpAnd,  OpPass,	'0'),  -- S_Idle
		  ('0',	Rx,	Rx,	Rx,     OpAnd,  OpPass,	'0'),  -- S_Idle
		  ('0',	Rx,	Rx,	Rx,     OpAnd,  OpPass,	'0')  -- S_Idle
		);

	COMPONENT dataPath
		GENERIC (
			Size  : INTEGER := 8; -- # bits in word
			ASize : INTEGER := 3  -- # bits in address
	);
		PORT (
			InPort      : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
			OutPort     : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
			Clk         : IN  STD_LOGIC;
			Instr       : IN Instruction_Type    
		);
	END COMPONENT;

	-- Datapath signals
	SIGNAL InPort      : STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
	SIGNAL OutPort     : STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
	SIGNAL instr : Instruction_type := ( '0' , Rx   , Rx   , Rx   , OpX   , OpX     , '0' );

	TYPE   State_Type IS (reset_state,S_ReadRed, S_ReadGreenWriteRed, S_ReadBlueWriteGreen, S_ProcessBlue, S_WriteBlue, S_Idle);

	SIGNAL current_state,   next_state   : State_Type;
	-- Instr counter for the datapath
	SIGNAL current_counter, next_counter : INTEGER RANGE 0 to ROM'High:= 0;
	SIGNAL read_address,next_read_address,write_address,next_write_address: STD_LOGIC_VECTOR(15 DOWNTO 0);

	SIGNAL next_WE,WE:STD_LOGIC:='0';

BEGIN

	instr   <= ROM(current_counter); -- Moore Decoding of instr...
	

	COMB: PROCESS(current_state, current_counter, read_address, write_address, InPort,OutPort,DataIn)
	BEGIN
		InPort <= DataIn;
		next_state   <= current_state;
		next_counter <= current_counter;
		Ready <= '0';
		next_read_address<=read_address;
		next_write_address<=write_address;
		next_WE<='0';
		CASE current_state IS
			WHEN reset_state => -- ROM Instr 0
				next_read_address<=(others=>'0');
				next_write_address<=(others=>'0');
				next_WE<='0';
				next_state<=S_ReadRed;
				next_counter   <= 1;
			WHEN S_ReadRed  => -- ROM Instr 1
				next_state<=S_ReadGreenWriteRed;
				next_counter   <= 2;
				next_read_address<=read_address+1;
				next_WE<='1'; -- Write during next state...
			WHEN S_ReadGreenWriteRed => -- ROM Instr 2
				next_counter <= 3;
				next_state   <= S_ReadBlueWriteGreen;
				next_read_address<=read_address+1;
				next_write_address<=write_address+1;
				next_WE<='1'; 
			WHEN S_ReadBlueWriteGreen => -- ROM Instr 3
				next_WE<='0'; --<='0'; if you add states for processing the blue color
				next_counter <= 4;
				next_state   <= S_ProcessBlue; --S_ProcessBlue;
				next_read_address<=read_address+1;
				next_write_address<=write_address+1;
			when S_ProcessBlue => -- ROM Instr 4 to 10
			  --next_WE<='0';
			  next_counter <= current_counter+1;
			  if(current_counter = 10) then
			    next_state <= S_WriteBlue;
			    next_WE <= '1';
			  end if;
			WHEN S_WriteBlue  => -- ROM Instr 10 or 11
				next_WE<='0';
				next_write_address<=write_address+1;
				next_state     <= S_Idle;
			WHEN S_Idle  =>
				if (read_address=57600) then
					Ready   <= '1';
				else
					next_state<=S_ReadRed;
					next_counter<=1;
				end if;
			WHEN OTHERS => 
				ASSERT false 
					report "illegal FSM state, testbench error"
					severity error;
		END CASE;
	END PROCESS;

P_SYNCH: PROCESS(Clk,reset)
	BEGIN
		IF (reset='0') then
			current_state<=reset_state;
			current_counter<=0;
			WE<='0';
		ELSIF rising_edge(Clk) THEN
			WE<=next_WE;
			read_address <= next_read_address;
			write_address <= next_write_address;
			current_state   <= next_state;
			current_counter <= next_counter;
		END IF;
	END PROCESS;

U_dataPath : dataPath
		GENERIC MAP(Size  => Size, ASize => ASize)
		PORT    MAP(				InPort      => InPort,
								OutPort     => OutPort,    
								Clk         => Clk,       
								Instr     => instr);

	-- Ensure an late write in the first Write state when addresses are stable
	RAM_WE<=WE AND not(clk);
	RAM_ADDRESS<=write_address;
	ROM_ADDRESS<=read_address;
	DataOut<=OutPort;

END behaviour;
