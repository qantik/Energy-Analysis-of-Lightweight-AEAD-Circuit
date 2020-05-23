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
          last_block    : in std_logic;
          empty_ad      : in std_logic;
          empty_msg     : in std_logic;
          incomplete    : in std_logic;

          domain        : out std_logic_vector(2 downto 0);
          nonce_ctr     : out std_logic_vector(7 downto 0);
          tag_sel       : out std_logic;
          ct_sel        : out std_logic;
          tag_enable    : out std_logic;
          
          cipher_ready  : out std_logic;
          tag_ready     : out std_logic;
          ready_block   : out std_logic;
          aead_done     : out std_logic        
          );
end;

architecture behaviour of aead_controller is

    signal counter_n, counter_p : integer range 0 to 63;
    signal very_last_block      : boolean; 
    signal very_first_block     : boolean;
    
    type FSM_State is (INIT, AD, MSG, DONE);
    signal state_p, state_n : FSM_State;

begin


    nonce_ctr <= std_logic_vector(to_unsigned(counter_p, 8));
    
    state_reg : process(clk, reset)
    begin
        if reset = '0' then
            state_p <= INIT;
            counter_p <= 0;
        elsif rising_edge(clk) then
            state_p <= state_n;
            counter_p <= counter_n;
        end if;
    end process;

    domain(0) <= '1' when last_block = '1' else '0';
    domain(1) <= '1' when incomplete = '1' and last_block = '1' else '0';
    domain(2) <= '1' when state_p = MSG else '0';

    tag_ready <= '1' when very_last_block else '0';
    cipher_ready <= '1' when state_p = MSG else '0';
    --aead_done <= '1' when last_block = '1' and (empty_msg = '1' or state_p = MSG) else '0';

    tag_sel <= '1' when very_first_block or (very_last_block and state_p = MSG) else '0';

    very_last_block <= last_block = '1' and (state_p = MSG or (state_p = AD and empty_msg = '1'));
    very_first_block <= counter_p = 1 and (state_p = AD or (state_p = MSG and empty_ad = '1'));
    
    aead_done <= '1' when very_last_block else '0';

    ct_sel <= '1' when very_last_block and state_p = MSG and not very_first_block else '0';
    tag_ready <= '1' when very_last_block else '0'; 

    counter_n <= 1 when (empty_msg = '0' and state_p = AD and last_block = '1') else counter_p + 1;

    ready_block <= '1' when state_p /= DONE and not very_last_block else '0';

    tag_enable <= '1' when state_p = INIT or state_p = DONE else '0';

    fsm : process(state_p, last_block, empty_ad, empty_msg)
    begin
        -- default 
        state_n <= state_p; 
        case state_p is
            when INIT =>
                if empty_ad = '0' then
                    state_n <= AD;
                else 
                    state_n <= MSG;
                end if;
            
            when AD =>
                if last_block = '1' then
                    if empty_msg = '1' then
                        state_n <= DONE;
                    else
                        state_n <= MSG;
                    end if;
                end if;
            
            when MSG =>
                if last_block = '1' then
                    state_n <= DONE;
                end if;

            when others =>
                    state_n <= DONE;

        end case;
    end process;

end;

