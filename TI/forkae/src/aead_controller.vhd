library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity aead_controller is
    port (clk           : in std_logic;
          reset         : in std_logic;
          core_done     : in std_logic;
          last_block    : in std_logic;
          empty_ad      : in std_logic;
          empty_msg     : in std_logic;
          incomplete    : in std_logic;

          domain        : out std_logic_vector(2 downto 0);
          core_reset    : out std_logic;
          nonce_ctr     : out std_logic_vector(7 downto 0);
          mode          : out std_logic;
          tag_sel       : out std_logic;
          ct_sel        : out std_logic;
          --mux_sel       : out std_logic_vector(1 downto 0);
          tag_clk_en    : out std_logic;
          
          in_ready      : out std_logic;
          cipher_ready  : out std_logic;
          tag_ready     : out std_logic;
          aead_done     : out std_logic        
          );
end;

architecture behaviour of aead_controller is

    signal counter_n, counter_p : integer range 0 to 63;

    signal C0_ready : boolean;
    signal C1_ready : boolean;
    signal processing_first_block : boolean;
    signal processing_last_block : boolean;


    signal core_reset_n : std_logic;

    type FSM_State is (INIT, AD, DONE, MSG_C1, MSG_C0);
    signal state_p, state_n : FSM_State;

begin


    nonce_ctr <= std_logic_vector(to_unsigned(counter_p, 8));
    
    mode <= '1' when state_p = AD else '0';
    core_reset_n <= '0' when state_p = INIT or state_p = DONE or C0_ready or (C1_ready and state_p = AD) else '1';
     
    domain(0) <= '1' when last_block = '1' else '0';
    domain(1) <= '1' when incomplete = '1' and last_block = '1' else '0';
    domain(2) <= '1' when state_p = MSG_C1 or state_p = MSG_C0 else '0';

    C0_ready <= core_done = '1' and state_p = MSG_C0;
    C1_ready <= core_done = '1' and (state_p = MSG_C1 or state_p = AD);

    tag_ready <= '1' when C1_ready and last_block = '1' and (not (state_p = AD and empty_msg = '0')) else '0';
    cipher_ready <= '1' when C0_ready else '0';
    -- check again

    processing_first_block <= counter_p = 1 and (state_p = AD or empty_ad = '1');
    processing_last_block <= last_block = '1' and not (state_p = AD and empty_msg = '0');

    tag_sel <= '1' when processing_first_block or (state_p = MSG_C1 and last_block = '1') else '0';
    ct_sel <= '1' when state_p = MSG_C0 and last_block = '1' else '0';
    tag_clk_en <= '0' when C1_ready and not processing_last_block else '1'; 
    in_ready <= '1' when state_p = INIT or (state_p = AD and C1_ready) or (C0_ready and not processing_last_block) else '0';
    aead_done <= '1' when last_block = '1' and (C0_ready or (C1_ready and empty_msg = '1')) else '0';


 state_reg : process(clk, reset)
    begin
        if reset = '0' then
            state_p <= INIT;
            counter_p <= 0;
            core_reset <= '0';
        elsif rising_edge(clk) then
            state_p <= state_n;
            counter_p <= counter_n;
            core_reset <= core_reset_n;
        end if;
    end process;

    fsm : process(state_p, core_done, last_block, empty_ad, empty_msg, counter_p, incomplete)
    begin
        -- default 
        state_n <= state_p; 
        counter_n <= counter_p;
        case state_p is
            when INIT =>
                counter_n <= counter_p + 1;
                if empty_ad = '0' then
                    state_n <= AD;
                else -- empty_ad = '1'
                    state_n <= MSG_C1;
                end if;
                
            when AD =>
                if core_done ='1' then
                    counter_n <= counter_p + 1;
                    if last_block = '1' then
                        state_n <= MSG_C1;
                        counter_n <= 1; -- reset counter
                        if empty_msg = '1' then
                            counter_n <= 0; -- just to be safe
                            state_n <= DONE;
                        end if;
                    end if;
                end if;
            
            when MSG_C1 =>
                if core_done = '1' then
                    state_n <= MSG_C0;
                end if;
            
            when MSG_C0 =>
                if core_done = '1' then
                    counter_n <= counter_p + 1;
                    state_n <= MSG_C1;
                    if last_block = '1' then
                        counter_n <= 0;
                        state_n <= DONE;
                    end if;
                end if;
                
            when others => -- DONE
                state_n <= DONE;
                counter_n <= 0;
            
        end case;
    end process;

end;

