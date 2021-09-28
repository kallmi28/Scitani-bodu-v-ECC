----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2019 07:44:34 PM
-- Design Name: 
-- Module Name: ecc - ecc_body
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
package ecc_parameters is
  constant M: integer := 79;
  constant F: std_logic_vector(M-1 downto 0):= (0=> '1', 9 => '1', others => '0'); 
    
  constant A_CONST: std_logic_vector(M-1 downto 0):= "100" & x"A2E38A8F66D7F4C385F";

end ecc_parameters;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ecc_parameters.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ecc is
    Port (  clk, rst, start_comp    : in std_logic;
            px, py, qx, qy          : in std_logic_vector (78 downto 0);
            rx, ry                  : out std_logic_vector (78 downto 0);
            done_ecc                : out std_logic);
end ecc;

architecture ecc_body of ecc is

component classic_squarer is
port (
  a: in std_logic_vector(M-1 downto 0);
  c: out std_logic_vector(M-1 downto 0)
);
end component classic_squarer;

component classic_multiplication is
port (
  a, b: in std_logic_vector(M-1 downto 0);
  c: out std_logic_vector(M-1 downto 0)
);
end component classic_multiplication;

component eea_inversion is
port (
  A: in std_logic_vector (M-1 downto 0);
  clk, reset, start: in std_logic; 
  Z: out std_logic_vector (M-1 downto 0);
  done: out std_logic
);
end component eea_inversion;

component adder2 is
    Port ( a: in std_logic_vector(78 downto 0);
           b: in std_logic_vector(78 downto 0);
           s: out std_logic_vector(78 downto 0));
end component adder2;

component adder3 is
    Port ( a: in std_logic_vector(78 downto 0);
           b: in std_logic_vector(78 downto 0);
           c: in std_logic_vector(78 downto 0);
           s: out std_logic_vector(78 downto 0));
end component adder3;

component adder5 is
    Port ( a: in std_logic_vector(78 downto 0);
           b: in std_logic_vector(78 downto 0);
           c: in std_logic_vector(78 downto 0);
           d: in std_logic_vector(78 downto 0);
           e: in std_logic_vector(78 downto 0);
           s: out std_logic_vector(78 downto 0));
end component adder5;

component controller_ecc is
    Port (  clk, reset : in std_logic;
            new_data   : in std_logic;
            done_inv   : in std_logic;
            store_lamb, store_rx, store_ry : out std_logic;
            start_inv  : out std_logic;
            phase  : out std_logic;
            done : out std_logic
            );
end component controller_ecc;

component dff is
generic (width: integer);
 port(  clk : in std_logic;
        rst : in std_logic;     
        ce : in std_logic;     
        d : in std_logic_vector (width - 1 downto 0);
        q : out std_logic_vector (width - 1 downto 0));
end component dff;


----------------------------------------------------------------------------------------

signal ecc_mux2adder2_1_a, ecc_mux2adder2_1_b    : std_logic_vector (78 downto 0);
signal ecc_mux2adder2_2_a                        : std_logic_vector (78 downto 0);
signal ecc_mux2invert                            : std_logic_vector (78 downto 0);
signal ecc_mux2lamb_d                            : std_logic_vector (78 downto 0);
signal ecc_mux2mult_a, ecc_mux2mult_b            : std_logic_vector (78 downto 0);

signal ecc_adder2_1Out, ecc_adder2_2Out          : std_logic_vector (78 downto 0);
signal ecc_adder3Out, ecc_adder5Out              : std_logic_vector (78 downto 0);
signal ecc_inv2mult                              : std_logic_vector (78 downto 0);
signal ecc_square2adder5_b                       : std_logic_vector (78 downto 0);
signal ecc_mult2adder2_2a                        : std_logic_vector (78 downto 0);
signal ecc_mult_out                              : std_logic_vector (78 downto 0);

signal d_lambda, d_rx, d_ry                      : std_logic_vector (78 downto 0);

----------------------------------------------------------------------------------------

signal contr_phase      : std_logic;
signal contr_start_inv  : std_logic;
signal contr_ld_lamb    : std_logic;
signal contr_ld_rx      : std_logic;
signal contr_ld_ry      : std_logic;
signal inv_done_inv     : std_logic;
signal comp_eq          : std_logic;

----------------------------------------------------------------------------------------    

begin

inst_mult:  classic_multiplication port map(a => ecc_mux2mult_a, b => ecc_mux2mult_b, c => ecc_mult_out);
inst_square:  classic_squarer port map(a => d_lambda, c => ecc_square2adder5_b);
inst_adder2_1:  adder2 port map(a => ecc_mux2adder2_1_a, b => ecc_mux2adder2_1_b, s => ecc_adder2_1Out);
inst_adder2_2:  adder2 port map(a => ecc_mux2adder2_2_a, b => qx, s => ecc_adder2_2Out);
inst_adder3:  adder3 port map(a => qy, b => ecc_mult_out, c => d_rx, s => ecc_adder3Out);
inst_adder5:  adder5 port map(a => d_lambda, b => ecc_square2adder5_b, c => A_CONST, d => px, e => qx, s => ecc_adder5Out);
inst_invert:  eea_inversion port map(A => ecc_mux2invert, clk => clk, reset => rst, start => contr_start_inv, Z => ecc_inv2mult,  done => inv_done_inv);
inst_control: controller_ecc port map (clk => clk, reset => rst, new_data => start_comp, done_inv => inv_done_inv, store_lamb => contr_ld_lamb, store_rx =>contr_ld_rx, store_ry => contr_ld_ry, start_inv => contr_start_inv, phase => contr_phase, done => done_ecc);

inst_dff_lamb : dff generic map (width => M) port map (clk => clk, rst => rst, ce => contr_ld_lamb, d => ecc_mux2lamb_d, q => d_lambda);
inst_dff_rx   : dff generic map (width => M) port map (clk => clk, rst => rst, ce => contr_ld_rx, d => ecc_adder5Out, q => d_rx);
inst_dff_ry   : dff generic map (width => M) port map (clk => clk, rst => rst, ce => contr_ld_ry, d => ecc_adder3Out, q => d_ry);

rx <= d_rx;
ry <= d_ry;


comp_eq <= '1' when (px = qx and py = qy) else '0';

ecc_mux2invert <= qx when comp_eq = '1' else ecc_adder2_2Out;
ecc_mux2mult_a <= qy when (comp_eq = '1' and contr_phase = '0') else ecc_adder2_1Out;
ecc_mux2mult_b <= d_lambda when contr_phase = '1' else ecc_inv2mult;
ecc_mux2adder2_1_a <= d_rx when contr_phase = '1' else py;
ecc_mux2adder2_1_b <= qx when contr_phase = '1' else qy;

ecc_mux2adder2_2_a <= ecc_mult_out when comp_eq = '1' else px;

ecc_mux2lamb_d <= ecc_adder2_2Out when comp_eq = '1' else ecc_mult_out;


end ecc_body;
