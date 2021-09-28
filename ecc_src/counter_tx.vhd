----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2019 06:55:44 PM
-- Design Name: 
-- Module Name: counter_tx - counter_tx_body
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

entity counter_tx is
    Port ( cnt_up : in STD_LOGIC;
           reset : in std_logic;
           cnt  : out std_logic_vector (4 downto 0));
end counter_tx;

architecture counter_tx_body of counter_tx is

signal counter : std_logic_vector (4 downto 0);

begin

process(reset, cnt_up)
begin
if(reset = '1') then
    counter <= (others=>'0');
elsif (rising_edge(cnt_up)) then
    counter <= counter + 1;
end if;
end process;
cnt <= counter;

end counter_tx_body;
