----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2019 05:04:07 PM
-- Design Name: 
-- Module Name: rx - Behavioral
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

package RS232_DEFINITIONS is
   constant BAUD_RATE               : integer := 115200;
   constant NO_OF_TRANSFERRED_BITS  : integer := 8;

   constant CLK_F                   : integer := 100000000;                    -- clock frequency of crystal (100 MHz)
   constant BIT_INTERVAL_TIME       : integer := (CLK_F/BAUD_RATE)-1;
   constant FIRST_BIT_INTERVAL_TIME : integer := (3*CLK_F)/(2*BAUD_RATE);
end package RS232_DEFINITIONS;


library IEEE;
use work.RS232_DEFINITIONS.all;
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

entity rx is
  Port (        RXD        : in  STD_LOGIC;                                             -- RxD serial in
                RXD_DATA   : out STD_LOGIC_VECTOR (NO_OF_TRANSFERRED_BITS-1 downto 0);  -- received data - parallel out
                RXD_STROBE : out STD_LOGIC;                                             -- high for 1 clock cycle upon data arrival
                
                CLK        : in  STD_LOGIC;
                RESET      : in  STD_LOGIC
       );
end rx;

architecture rx_body of rx is

   -----------------------------------------------------
   -- RXD ----------------------------------------------
   -----------------------------------------------------
   type   TYPE_RX_STATE is (START, INIT, SEND, ACK);

   signal RX_BIT_INTERVAL      : std_logic_vector(15 downto 0);
   signal RX_LOAD_BIT_INTERVAL : std_logic;
   signal RX_LOAD_FIRST_BIT_INTERVAL : std_logic;
   signal RX_EN_BIT_INTERVAL   : std_logic;
   signal RX_BIT_INTERVAL_END  : std_logic;

   signal RX_BIT_COUNTER       : std_logic_vector(3 downto 0);
   signal RX_LOAD_BIT_COUNTER  : std_logic;
   signal RX_EN_BIT_COUNTER    : std_logic;
   signal RX_BIT_COUNTER_END   : std_logic;

   signal RXD_DATA_REG         : std_logic_vector (NO_OF_TRANSFERRED_BITS-1 downto 0);
   signal RX_EN_DATA_OUT       : std_logic;

   signal RX_STATE, RX_NEXT_STATE : TYPE_RX_STATE;

   -- input synchronizer signals
   signal RXD_Q : std_logic;
   signal RXD_QQ : std_logic;


begin
   -----------------------------------------------------
   -----------------------------------------------------
   -- RXD ----------------------------------------------
   -----------------------------------------------------
   -----------------------------------------------------

   ---------------------------------------------
   -- INPUT SYNCHRONIZATION    -----------------
   ---------------------------------------------
   RXD_SYNCHRONIZER : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         RXD_Q  <= RXD;
         RXD_QQ <= RXD_Q;
      end if;
   end process;
   

   ---------------------------------------------
   -- BIT INTERVAL MEASUREMENT -----------------
   -- measures time of one bit transfer in a BIT_RATE
   ---------------------------------------------
   RX_BIT_INTERVAL_MEASUREMENT : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RX_LOAD_BIT_INTERVAL = '1' then
            RX_BIT_INTERVAL <= conv_std_logic_vector(BIT_INTERVAL_TIME,16);
         elsif RX_LOAD_FIRST_BIT_INTERVAL = '1' then
            RX_BIT_INTERVAL <= conv_std_logic_vector(FIRST_BIT_INTERVAL_TIME,16);
         elsif RX_EN_BIT_INTERVAL = '1' then
            RX_BIT_INTERVAL <= RX_BIT_INTERVAL - 1;
         end if;
      end if;
   end process;
   
   RX_BIT_INTERVAL_END <= '1' when (RX_BIT_INTERVAL = conv_std_logic_vector(0,16)) else
                          '0';


   ---------------------------------------------
   -- BIT COUNTING -----------------------------
   -- counts bits to be send
   ---------------------------------------------
   RX_BIT_COUNTING : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RX_LOAD_BIT_COUNTER = '1' then
            RX_BIT_COUNTER <= conv_std_logic_vector(NO_OF_TRANSFERRED_BITS,4);
         elsif RX_EN_BIT_COUNTER = '1' then
            RX_BIT_COUNTER <= RX_BIT_COUNTER - 1;
         end if;
      end if;
   end process;
   
   RX_BIT_COUNTER_END <= '1' when (RX_BIT_COUNTER = conv_std_logic_vector(0,4)) else
                         '0';

   
   ---------------------------------------------
   -- FSM --------------------------------------
   -- controls RxD -----------------------------
   ---------------------------------------------
   RX_FSM_TRANSITION_AND_OUTPUT : process (RX_STATE, RXD_QQ, RX_BIT_INTERVAL_END, RX_BIT_COUNTER_END)
   begin
      RX_LOAD_BIT_COUNTER  <= '0';
      RX_EN_BIT_COUNTER    <= '0';
      RX_LOAD_BIT_INTERVAL <= '0';
      RX_LOAD_FIRST_BIT_INTERVAL <= '0';
      RX_EN_BIT_INTERVAL   <= '0';
      RXD_STROBE           <= '0';
      RX_EN_DATA_OUT       <= '0';
      
   
      case RX_STATE is
         when START => if RXD_QQ = '0' then
                          RX_NEXT_STATE <= INIT;
                          ---------------------
                          RX_LOAD_BIT_COUNTER <= '1';
                       else
                          RX_NEXT_STATE <= START;
                       end if;

         when INIT  =>    RX_NEXT_STATE <= SEND;
                          ------------------------
                          RX_LOAD_FIRST_BIT_INTERVAL <= '1';

         when SEND  => if RX_BIT_INTERVAL_END = '0' then
                          RX_NEXT_STATE <= SEND;
                          ---------------------
                          RX_EN_BIT_INTERVAL <= '1';
                       elsif RX_BIT_COUNTER_END = '0' then
                            RX_NEXT_STATE <= SEND;
                          ---------------------
                          RX_LOAD_BIT_INTERVAL <= '1';
                          RX_EN_BIT_COUNTER <= '1';
                       else         
                          RX_NEXT_STATE  <= ACK;
                          RX_EN_DATA_OUT <= '1';
                       end if;
         when ACK   =>    RX_NEXT_STATE <= START;
                          RXD_STROBE <= '1';
      end case;
   end process;

   RX_FSM_REG : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RESET = '1' then
            RX_STATE <= START;
         else
            RX_STATE <= RX_NEXT_STATE;
         end if;
      end if;
   end process;



   ---------------------------------------------
   -- RXD shift register -----------------------
   ---------------------------------------------
   RXD_SHIFT_REG : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RESET = '1' then
            RXD_DATA_REG <= (others => '0');
         else
            if RX_EN_BIT_COUNTER = '1' then
               RXD_DATA_REG <= RXD_QQ & RXD_DATA_REG(NO_OF_TRANSFERRED_BITS-1 downto 1);
            end if;
         end if;
      end if;
   end process;
   
   
   ---------------------------------------------
   -- RXD capture register ---------------------
   ---------------------------------------------
   RXD_CAPTURE_REG : process(CLK)
   begin
      if CLK = '1' and CLK'event then
         if RESET = '1' then
            RXD_DATA <= (others => '0');
         elsif RX_EN_DATA_OUT = '1' then
            RXD_DATA <= RXD_DATA_REG;
         end if;
      end if;
   end process;


end rx_body;
