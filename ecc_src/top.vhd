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

entity top is
    Port (  clk, reset  : in std_logic;
            rxd         : in std_logic;
            btn_u         : in std_logic;
            btn_d         : in std_logic;
            cnt_rx      : out std_logic_vector (5 downto 0);
            cnt_seg      : out std_logic_vector (4 downto 0);
            seg_segment : out STD_LOGIC_VECTOR (6 downto 0);
            seg_anode : out STD_LOGIC_VECTOR (3 downto 0);
            txd         : out std_logic );
end top;

architecture top_body of top is

component top_ecc is
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
end component top_ecc;

component eea_inversion is
port (
  A: in std_logic_vector (78 downto 0);
  clk, reset, start: in std_logic; 
  Z: out std_logic_vector (78 downto 0);
  done: out std_logic
);
end component eea_inversion;

component rx is
  Port (        RXD        : in  STD_LOGIC;                                             -- RxD serial in
                RXD_DATA   : out STD_LOGIC_VECTOR (7 downto 0);  -- received data - parallel out
                RXD_STROBE : out STD_LOGIC;                                             -- high for 1 clock cycle upon data arrival
                
                CLK        : in  STD_LOGIC;
                RESET      : in  STD_LOGIC
       );
end component rx;

component tx is
   port (
      TXD_DATA   : in  STD_LOGIC_VECTOR (7 downto 0);  -- transmitted data - parallel in
      TXD_STROBE : in  STD_LOGIC;                                             -- start of transmission
      TXD        : out STD_LOGIC;                                             -- TxD serial out
      TXD_READY  : out STD_LOGIC;                                             -- high when ready for transmission

      CLK        : in  STD_LOGIC;
      RESET      : in  STD_LOGIC
   );
end component tx;



component counter_rx is
    Port ( cnt_up : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           cnt : out std_logic_vector (5 downto 0));
end component counter_rx;

component counter_tx is
    Port ( 
       cnt_up : in STD_LOGIC;
       clk : in STD_LOGIC;
       reset : in std_logic;
       cnt  : out std_logic_vector (4 downto 0));
end component counter_tx;


component top_control_rx is
	Port ( clk, reset	: in std_logic;
		   rx_cnt		: in std_logic_vector(5 downto 0);
		   rx_ack		: in std_logic;
		   cnt_up		: out std_logic;
		   start_next	: out std_logic;
		   reset_cnt	: out std_logic
		   );
end component top_control_rx;

component top_controller_out is
    Port ( clk, reset : in std_logic;
           button_r, button_l : in std_logic;
           counter : out std_logic_vector (5 downto 0) );
end component top_controller_out;

component sevenseg is
   port (
      DATA    : in   STD_LOGIC_VECTOR (15 downto 0);  
      CLK     : in   STD_LOGIC;
      ANODE   : out  STD_LOGIC_VECTOR (3 downto 0);
      SEGMENT : out  STD_LOGIC_VECTOR (6 downto 0)
	);
end component sevenseg;

component debounce is
    Generic (width: integer := 22); -- 100 MHz clock -> 4 - simulation (90 ns); 22 - synthesis (ca. 20 ms)
    Port ( clk : in STD_LOGIC;
           tl_in : in STD_LOGIC;
           tl_out : out STD_LOGIC);
end component debounce;
---------------------------------------------------------------------------------------------------------------

signal control_start_ecc, control_start_tx : std_logic;
signal control_rx_cnt_up : std_logic;
signal control_tx_cnt_up : std_logic;
signal control_cnt_tx_reset : std_logic;
signal control_cnt_rx_reset : std_logic;
signal control_rx_ack : std_logic;


signal rx_counter : std_logic_vector(5 downto 0);
signal tx_counter : std_logic_vector(4 downto 0);


signal rx_data_out : std_logic_vector (7 downto 0);


signal data_in : std_logic_vector (319 downto 0);
signal data_out : std_logic_vector (159 downto 0);
signal data_out_ecc : std_logic_vector (159 downto 0);

signal seg_cnt      : std_logic_vector (5 downto 0);
signal seg_data     : std_logic_vector(15 downto 0);

signal debounce_up, debounce_down : std_logic;

---------------------------------------------------------------------------------------------------------------
begin

deb_up: debounce port map (clk => clk, tl_in => btn_u, tl_out => debounce_up);
deb_down: debounce port map (clk => clk, tl_in => btn_d, tl_out => debounce_down);



top_seg : sevenseg port map(data => seg_data, clk => clk, anode => seg_anode, segment => seg_segment);
top_controller_seg :  top_controller_out port map (clk => clk, reset => reset, button_r => debounce_up, button_l => debounce_down, counter => seg_cnt);

process (clk)
begin

if(clk'event and clk = '1') then
    seg_data <= data_out_ecc(conv_integer(seg_cnt) * 16 + 15 downto conv_integer(seg_cnt) * 16);
end if;
end process;

cnt_seg <= seg_cnt(4 downto 0);
---------------------------------------------------------------------------------------------------------------
top_rx_inst         : rx port map (rxd => rxd, rxd_data => rx_data_out, rxd_strobe => control_rx_ack, clk => clk, reset => reset);
top_cnt_rx_inst     : counter_rx port map (cnt_up => control_rx_cnt_up, clk => clk, reset => control_cnt_rx_reset, cnt => rx_counter);
top_control_rx_inst : top_control_rx port map (clk => clk, reset => reset, rx_cnt => rx_counter, rx_ack => control_rx_ack, cnt_up => control_rx_cnt_up, start_next => control_start_ecc, reset_cnt => control_cnt_rx_reset);

cnt_rx <= rx_counter;
data_in <= data_in(311 downto 0) & rx_data_out when (rising_edge(clk) and control_rx_cnt_up = '1') else data_in;


--top_tx_inst         : tx port map (txd => txd, txd_data => tx_data_in, txd_strobe => control_tx_start, txd_ready=> control_tx_sent, clk => clk, reset => reset);
--top_cnt_tx_inst     : counter_tx port map (cnt_up => control_tx_cnt_up, reset => control_cnt_tx_reset);


top_ecc_inst        : top_ecc port map (px => data_in(319 downto 240), py => data_in(239 downto 160), qx => data_in(159 downto 80), qy => data_in(79 downto 0), clk => clk, reset => reset, start => control_start_ecc, done => control_start_tx, rx => data_out_ecc(159 downto 80), ry => data_out_ecc(79 downto 0));

end top_body;
