----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2019 05:01:01 PM
-- Design Name: 
-- Module Name: top_controller_out - top_controller_out_body
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_controller_out is
    Port ( clk, reset : in std_logic;
           button_r, button_l : in std_logic;
           counter : out std_logic_vector (5 downto 0) );
end top_controller_out;

architecture top_controller_out_body of top_controller_out is
signal cnt : std_logic_vector (5 downto 0);
type fsm_state is (A, B, C);
signal state, nextstate : fsm_state;

begin


counter <= cnt;

process(clk)
begin
if rising_edge(clk) then
    if(reset = '1') then
        cnt <= (others => '0');
    elsif(state = A and button_l = '1') then
        cnt <= cnt + 1;
        if( cnt = 9) then
            cnt <= (others => '0');
        end if;
    elsif (state = A and button_r = '1') then
        cnt <= cnt - 1;
        if( cnt = 0) then
            cnt <= "001001";
        end if;
    end if;
end if;
end process;


CLOCK: process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			state <= A;
	    else 
			state <= nextstate;
		end if;
	end if;
end process;

TRANSITION : process(state, button_l, button_r)
begin
nextstate <= state;
case state is
		when A => 
		  if(button_l = '1')then
		      nextstate <= B;
		  elsif (button_r = '1') then
		      nextstate <= C;
		  end if;
		when B => 
		  if(button_l = '0') then
		      nextstate <= A;
		  end if;
		when C =>
		  if(button_r = '0') then
		      nextstate <= A;
		  end if; 
end case;
end process;




end top_controller_out_body;
