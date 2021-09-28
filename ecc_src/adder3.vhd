----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2019 04:58:30 PM
-- Design Name: 
-- Module Name: adder2 - Behavioral
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder3 is
    Port ( a: in std_logic_vector(78 downto 0);
           b: in std_logic_vector(78 downto 0);
           c: in std_logic_vector(78 downto 0);
           s: out std_logic_vector(78 downto 0));
end adder3;

architecture adder3_body of adder3 is

begin

s <= a xor b xor c;

end adder3_body;
