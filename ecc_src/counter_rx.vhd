----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2019 06:55:44 PM
-- Design Name: 
-- Module Name: counter_rx - counter_rx_body
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

entity counter_rx is
    Port ( cnt_up : in STD_LOGIC;
           clk : in std_logic; 
           reset : in STD_LOGIC;
           cnt : out std_logic_vector (5 downto 0));
end counter_rx;

architecture counter_rx_body of counter_rx is

signal counter : std_logic_vector (5 downto 0);

begin


process(clk)
begin
if (rising_edge(clk)) then
  if(reset = '1') then
      counter <= (others=>'0');
  elsif (cnt_up = '1') then
      counter <= counter + 1;
  end if;
end if;
end process;


cnt <= counter;

end counter_rx_body;
