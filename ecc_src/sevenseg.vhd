library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sevenseg is
   port (
      DATA    : in   STD_LOGIC_VECTOR (15 downto 0);  
      CLK     : in   STD_LOGIC;
      ANODE   : out  STD_LOGIC_VECTOR (3 downto 0);
      SEGMENT : out  STD_LOGIC_VECTOR (6 downto 0)
	);
end sevenseg;

architecture sevenseg_body of sevenseg is
   constant COUNTER_WIDTH : integer := 16;

   signal COUNTER : std_logic_vector (COUNTER_WIDTH-1 downto 0);
	signal HEXDATA : std_logic_vector (3 downto 0);
	

begin

   process (CLK)
	begin
	   if CLK = '1' and CLK'event then
		   COUNTER <= COUNTER + 1;
		end if;
	end process;
	
	process (COUNTER, DATA)
	begin
	   case COUNTER(COUNTER_WIDTH-1 downto COUNTER_WIDTH-2) is
		   when "00"   => HEXDATA <= DATA( 3 downto 0);
		   when "01"   => HEXDATA <= DATA( 7 downto 4);
		   when "10"   => HEXDATA <= DATA(11 downto 8);
		   when others => HEXDATA <= DATA(15 downto 12);
		end case;
	end process;
	
   with HEXDATA select
   SEGMENT <= "1111001" when "0001",   --1
              "0100100" when "0010",   --2
              "0110000" when "0011",   --3
              "0011001" when "0100",   --4
              "0010010" when "0101",   --5
              "0000010" when "0110",   --6
              "1111000" when "0111",   --7
              "0000000" when "1000",   --8
              "0010000" when "1001",   --9
              "0001000" when "1010",   --A
              "0000011" when "1011",   --b
              "1000110" when "1100",   --C
              "0100001" when "1101",   --d
              "0000110" when "1110",   --E
              "0001110" when "1111",   --F
              "1000000" when others;   --0
			
	
	with COUNTER(COUNTER_WIDTH-1 downto COUNTER_WIDTH-2) select
	ANODE <= "1110" when "00",
	         "1101" when "01",
				"1011" when "10",
				"0111" when others;	

end sevenseg_body;