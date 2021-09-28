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

entity tx is
   port (
      TXD_DATA   : in  STD_LOGIC_VECTOR (NO_OF_TRANSFERRED_BITS-1 downto 0);  -- transmitted data - parallel in
      TXD_STROBE : in  STD_LOGIC;                                             -- start of transmission
      TXD        : out STD_LOGIC;                                             -- TxD serial out
      TXD_READY  : out STD_LOGIC;                                             -- high when ready for transmission

      CLK        : in  STD_LOGIC;
      RESET      : in  STD_LOGIC
   );
end tx;



architecture tx_body of tx is
   -----------------------------------------------------
   -- TXD ----------------------------------------------
   -----------------------------------------------------
   type   TYPE_TX_STATE is (START, INIT, SEND);

   signal TX_BIT_INTERVAL      : std_logic_vector(15 downto 0);
   signal TX_LOAD_BIT_INTERVAL : std_logic;
   signal TX_EN_BIT_INTERVAL   : std_logic;
   signal TX_BIT_INTERVAL_END  : std_logic;

   signal TX_BIT_COUNTER       : std_logic_vector(3 downto 0);
   signal TX_LOAD_BIT_COUNTER  : std_logic;
   signal TX_EN_BIT_COUNTER    : std_logic;
   signal TX_BIT_COUNTER_END   : std_logic;

   signal TXD_DATA_REG         : std_logic_vector (NO_OF_TRANSFERRED_BITS+2 downto 0);

   signal TX_STATE, TX_NEXT_STATE : TYPE_TX_STATE;



begin
   -----------------------------------------------------
   -----------------------------------------------------
   -- TXD ----------------------------------------------
   -----------------------------------------------------
   -----------------------------------------------------




   ---------------------------------------------
   -- BIT INTERVAL MEASUREMENT -----------------
   -- measures time of one bit transfer in a BIT_RATE
   ---------------------------------------------
   TX_BIT_INTERVAL_MEASUREMENT : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if TX_LOAD_BIT_INTERVAL = '1' then
            TX_BIT_INTERVAL <= conv_std_logic_vector(BIT_INTERVAL_TIME,16);
         elsif TX_EN_BIT_INTERVAL = '1' then
            TX_BIT_INTERVAL <= TX_BIT_INTERVAL - 1;
         end if;
      end if;
   end process;
   
   TX_BIT_INTERVAL_END <= '1' when (TX_BIT_INTERVAL = conv_std_logic_vector(0,16)) else
                          '0';


   ---------------------------------------------
   -- BIT COUNTING -----------------------------
   -- counts bits to be send
   ---------------------------------------------
   TX_BIT_COUNTING : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if TX_LOAD_BIT_COUNTER = '1' then
            TX_BIT_COUNTER <= conv_std_logic_vector(NO_OF_TRANSFERRED_BITS+2,4);
         elsif TX_EN_BIT_COUNTER = '1' then
            TX_BIT_COUNTER <= TX_BIT_COUNTER - 1;
         end if;
      end if;
   end process;
   
   TX_BIT_COUNTER_END <= '1' when (TX_BIT_COUNTER = conv_std_logic_vector(0,4)) else
                         '0';

   
   ---------------------------------------------
   -- FSM --------------------------------------
   -- controls TxD -----------------------------
   ---------------------------------------------
   TX_FSM_TRANSITION_AND_OUTPUT : process (TX_STATE, TXD_STROBE, TX_BIT_INTERVAL_END, TX_BIT_COUNTER_END)
   begin
      TX_LOAD_BIT_COUNTER  <= '0';
      TX_EN_BIT_COUNTER    <= '0';
      TX_LOAD_BIT_INTERVAL <= '0';
      TX_EN_BIT_INTERVAL   <= '0';
      TXD_READY            <= '0';
      
   
      case TX_STATE is
         when START => if TXD_STROBE = '1' then
                          TX_NEXT_STATE <= INIT;
                          ---------------------
                          TXD_READY <= '1';
                          TX_LOAD_BIT_COUNTER <= '1';
                       else
                          TX_NEXT_STATE <= START;
                          ---------------------
                          TXD_READY <= '1';
                       end if;

         when INIT  =>    TX_NEXT_STATE <= SEND;
                          ------------------------
                          TX_LOAD_BIT_INTERVAL <= '1';
                          TX_EN_BIT_COUNTER <= '1';

         when SEND  => if TX_BIT_INTERVAL_END = '0' then
                          TX_NEXT_STATE <= SEND;
                          ---------------------
                          TX_EN_BIT_INTERVAL <= '1';
                       elsif TX_BIT_COUNTER_END = '0' then
                          TX_NEXT_STATE <= SEND;
                          ---------------------
                          TX_LOAD_BIT_INTERVAL <= '1';
                          TX_EN_BIT_COUNTER <= '1';
                       else         
                          TX_NEXT_STATE <= START;
                       end if;
      end case;
   end process;

   TX_FSM_REG : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RESET = '1' then
            TX_STATE <= START;
         else
            TX_STATE <= TX_NEXT_STATE;
         end if;
      end if;
   end process;



   ---------------------------------------------
   -- TXD SHIFT REGISTER -----------------------
   ---------------------------------------------
   TX_SHIFT_REG : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RESET = '1' then
            TXD_DATA_REG <= (others => '1');
         else
            if TX_LOAD_BIT_COUNTER = '1' then
               TXD_DATA_REG(0)  <= '1';               -- pre-start bit
               TXD_DATA_REG(1)  <= '0';               -- start bit
               TXD_DATA_REG(NO_OF_TRANSFERRED_BITS+1 downto 2) <= TXD_DATA;  -- data bits
               TXD_DATA_REG(NO_OF_TRANSFERRED_BITS+2) <= '1';               -- stop bit
            elsif TX_EN_BIT_COUNTER = '1' then
               TXD_DATA_REG <= '1' & TXD_DATA_REG(10 downto 1);
            end if;
         end if;
      end if;
   end process;
   
   
   TXD <= TXD_DATA_REG(0);


end tx_body;