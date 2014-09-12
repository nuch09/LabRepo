USE WORK.ALL; -- Search for            components in work library
LIBRARY IEEE; -- These lines           informs the the compiler thatthe library IEEE
               -- is used
USE IEEE.std_logic_1164.all;             -- contains some conversionfunctions
USE IEEE.numeric_std.all;                -- contains more conversionfunctions

ARCHITECTURE ALUTest OF test IS

   constant width : INTEGER := 8;
   SIGNAL a,b,q:bit_vector(width-1 downto 0);
   SIGNAL ctrl:bit_vector (1 DOWNTO 0);
   SIGNAL cout,cin:bit:='0';

   COMPONENT alu
     GENERIC (size: INTEGER:=4);
     PORT (
       a:IN bit_vector (size-1 downto 0);
       b:IN bit_vector (size-1 downto 0);
       ctrl:IN bit_vector (1 downto 0);
       q:OUT bit_vector (size-1 downto 0);
       cout:OUT bit);
   END COMPONENT;

  FUNCTION to_bitvector(a:INTEGER;length:NATURAL) RETURN
bit_vector IS
    -- This function converts an integer to a bitvecor oflength.
    -- To do this conversion are conversion functions from
    -- the IEEE package used.
  BEGIN
    RETURN to_bitvector(std_logic_vector
(to_signed(a,length)));
  END;
  -- The statements inside a Procedure and a function is executed in sequence.

PROCEDURE behave_alu(a:INTEGER; b:INTEGER;ctrl:INTEGER;
                  q:OUT bit_vector(width-1 downto 0);
cout: OUT bit) IS
    -- This is a behavioral model of the ALU.
    VARIABLE ret: bit_vector(width downto 0);
  BEGIN
    CASE ctrl IS
      -- width+1 for compensating for cout
      WHEN 0 => ret := to_bitvector(a+b, width+1);
      WHEN 1 => ret := to_bitvector(a-b,width+1);
                ret(width):= not ret(width);
      -- & means concatenation
      WHEN 2 => ret := '0' &
      (to_bitvector(a,width) nand to_bitvector(b,width));
      WHEN 3 => ret := '0'&
      (to_bitvector(a,width) nor to_bitvector(b,width));
      WHEN OTHERS =>
          ASSERT false
          REPORT "CTRL out of range, testbench error"
          SEVERITY error ;
    END CASE;
    q := ret(width-1 downto 0);
    cout := ret(width);
  END;

BEGIN
  -- The key world process means that the code inside the process
  -- is executed serially.
  PROCESS
    -- These variables are only valid inside a processes.
     -- The biggest difference from a signal in that they
    -- are uppdated immediately. Not at the nearest break.
    VARIABLE res:bit_vector ( width-1 downto 0);
    VARIABLE int_CTRL: bit_vector ( 2 downto 0);
    VARIABLE c:bit;
  BEGIN
    FOR i IN 0 TO width-1 LOOP
      a<= to_bitvector(i,width);
      FOR j IN 0 TO width LOOP
        b<= to_bitvector(j,width);
        FOR k IN 0 TO 3 LOOP
          ctrl<= to_bitvector(k,3)(1 downto 0);
          wait for 10 ns;
          behave_alu(i,j,k,res,c);
          -- Assert that q = res, otherwise is
          -- the messaege wrong result from ALU
          -- displayed in ModelSim EE window.
          ASSERT q = res

        REPORT "wrong result from ALU"
             SEVERITY warning;
           ASSERT cout = c
             REPORT "wrong carry from ALU"
             SEVERITY warning;
         END LOOP;
       END LOOP;
     END LOOP;
     wait;
   END PROCESS;

   T1:alu GENERIC MAP(width)
       PORT MAP (a,b,ctrl,q,cout);

END ALUTest;
