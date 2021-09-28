library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_ecc is
    Port (  px : in STD_LOGIC_VECTOR (79 downto 0);
            py : in STD_LOGIC_VECTOR (79 downto 0);
            qx : in STD_LOGIC_VECTOR (79 downto 0);
            qy : in STD_LOGIC_VECTOR (79 downto 0);
            clk, reset : in std_logic;
            start : in std_logic;
            
            done : out std_logic;
            rx : out STD_LOGIC_VECTOR (79 downto 0);
            ry : out STD_LOGIC_VECTOR (79 downto 0)                        
    );
end top_ecc;

architecture top_ecc_body of top_ecc is

constant M: integer := 79;

component ecc is
    Port (  clk, rst, start_comp    : in std_logic;
            px, py, qx, qy          : in std_logic_vector (78 downto 0);
            rx, ry                  : out std_logic_vector (78 downto 0);
            done_ecc                : out std_logic);
end component ecc;


component top_control_ecc is
  Port (  clk, reset  : in std_logic;
      start : in std_logic;
      p0, q0 : in std_logic;
      op1 : in std_logic;
      ecc_done : in std_logic;

      copyP : out std_logic;
      ecc_start : out std_logic;
      start_next : out std_logic
       );
end component top_control_ecc;

signal top_px, top_py : std_logic_vector (79 downto 0);
signal top_qx, top_qy : std_logic_vector (79 downto 0);

signal top_rx, top_ry : std_logic_vector (79 downto 0);

signal top_ecc_rx, top_ecc_ry : std_logic_vector (78 downto 0);

signal top_px2ecc, top_py2ecc : std_logic_vector (78 downto 0);
signal top_qx2ecc, top_qy2ecc : std_logic_vector (78 downto 0);

signal top_p0, top_q0 : std_logic;
signal top_inv_start, top_op2 : std_logic;
signal top_inv_done : std_logic;
signal top_op1 : std_logic;

signal top_ecc_start, top_ecc_done : std_logic;


signal top_qy_ecc : std_logic_vector (78 downto 0);

signal top_r0 : std_logic;
signal top_copyP : std_logic;
constant ZERO : std_logic_vector(78 downto 0) := (others => '0');

begin

top_px <= px;
top_py <= py;
top_qx <= qx;
top_qy <= qy;

rx <= top_rx;
ry <= top_ry;


inst_ecc : ecc port map (clk => clk, rst => reset, start_comp => top_ecc_start, px => top_px2ecc,
  py => top_py2ecc, qx => top_qx2ecc, qy => top_qy_ecc, rx => top_ecc_rx, ry => top_ecc_ry, done_ecc => top_ecc_done);


inst_control : top_control_ecc port map (clk => clk, reset => reset, start => start, p0 => top_p0, q0 => top_q0,
 op1 => top_op1, ecc_done => top_ecc_done, copyP => top_copyP, ecc_start => top_ecc_start, start_next => done);


top_r0 <= '1' when ((top_px2ecc = top_qx2ecc and top_py2ecc /= top_qy2ecc) or (top_px2ecc = top_qx2ecc and top_py2ecc = top_qy2ecc and top_px2ecc = ZERO)) else '0';

top_op2 <= top_qy(79);
top_op1 <= top_px(79);
top_px2ecc <= top_px(78 downto 0);
top_py2ecc <= top_py(78 downto 0);
top_qx2ecc <= top_qx(78 downto 0) when (top_op1 = '0') else top_px(78 downto 0);
top_qy2ecc <= top_qy(78 downto 0) when (top_op1 = '0') else top_py(78 downto 0);



top_qy_ecc <= top_qy2ecc when (top_op2 = '0') else (top_qy2ecc xor top_qx2ecc);

top_p0 <= '1' when (top_px(78 downto 0) = 0 and top_py(78 downto 0) = 0) else '0';
top_q0 <= '1' when (top_qx(78 downto 0) = 0 and top_qy(78 downto 0) = 0) else '0';


top_rx <= ('0' & top_px (78 downto 0)) when (top_q0 = '1') else
          ('0' & top_qx (78 downto 0)) when (top_p0 = '1') else
          (others => '0') when (top_r0 = '1') else
          ('0' & top_ecc_rx);

top_ry <= ('0' & top_py (78 downto 0)) when (top_q0 = '1') else
          ('0' & top_qy (78 downto 0)) when (top_p0 = '1') else
          (others => '0') when (top_r0 = '1') else
          ('0' & top_ecc_ry);

end top_ecc_body;
