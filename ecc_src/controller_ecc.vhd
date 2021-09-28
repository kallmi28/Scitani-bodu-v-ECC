----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2019 02:53:20 PM
-- Design Name: 
-- Module Name: controller_ecc - controller_ecc_body
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_ecc is
    Port (  clk, reset : in std_logic;
            new_data   : in std_logic;
            done_inv   : in std_logic;
            store_lamb, store_rx, store_ry : out std_logic;
            start_inv  : out std_logic;
            phase      : out std_logic;
            done       : out std_logic
            );
end controller_ecc;

architecture controller_ecc_body of controller_ecc is

type fsm_state is (WAITING, INIT, W1, W2, INVERT, ST_LAMB, W3, ST_RX, W4, W5, ST_RY);
signal state, nextstate : fsm_state;


begin


CLOCK: process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then 
			state <= WAITING;
		else 
			state <= nextstate;
		end if;
	end if;
end process;

TRANSITION : process(state, new_data, done_inv)
begin
nextstate <= state;
case state is
		when WAITING =>
		  if(new_data = '1') then
		      nextstate <= INIT;
		  end if;
		when INIT =>
		  nextstate <= W1;
		when W1 =>
		  nextstate <= W2;
		when W2 =>
		  nextstate <= INVERT;
		when INVERT =>
		  if(done_inv = '1') then
            nextstate <= ST_LAMB;
          else
            nextstate <= INVERT;
          end if;		
		when ST_LAMB =>
		  nextstate <= W3;
		when W3 =>
		  nextstate <= ST_RX;
		when ST_RX =>
		  nextstate <= W4;
		when W4 =>
		  nextstate <= W5;
		when W5 =>
		  nextstate <= ST_RY;
		when ST_RY =>
		  nextstate <= WAITING;
end case;
end process;


OUTPUT : process(state, new_data, done_inv)
begin

start_inv <= '0';
store_lamb <='0'; 
store_rx <='0';
store_ry <='0';
phase <= '0';
done <= '0';
case state is
		when W2 =>
		    start_inv <= '1';

		when ST_LAMB =>
		    store_lamb <='1'; 
        when W3 =>
            phase <= '1';
		when ST_RX =>
            store_rx <='1';
            phase <= '1';
        when W4 =>
            phase <= '1';
        when W5 =>
            phase <= '1';                
		when ST_RY =>
		    store_ry <='1';
		    phase <= '1';
		    done <= '1';
		when others => NULL;

end case;
end process;


end controller_ecc_body;
