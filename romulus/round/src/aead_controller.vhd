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

          domain        : out std_logic_vector(4 downto 0);
          core_reset    : out std_logic;
          lfsr          : out std_logic_vector(55 downto 0);
          tag_sel       : out std_logic;
          rho_sel       : out std_logic;
          tweak_sel     : out std_logic;
          state_sel     : out std_logic;
          tag_clk_en    : out std_logic;
          
          read_block    : out std_logic;
          cipher_ready  : out std_logic;
          tag_ready     : out std_logic;
          aead_done     : out std_logic        
          );
end;

architecture behaviour of aead_controller is

    constant LFSR_ZERO      : std_logic_vector(55 downto 0) := X"00000000000001";
    constant LFSR_ONE       : std_logic_vector(55 downto 0) := X"00000000000002";

    signal lfsr_p, lfsr_plus_one, lfsr_n : std_logic_vector(55 downto 0);

    signal first_block_p, first_block_n : boolean;

    signal core_reset_n : std_logic;

    type FSM_State is (INIT, AD_EVEN, AD_ODD, NONCE, TAG, DONE, MSG, MSG_NONCE);
    signal state_p, state_n : FSM_State;

begin


    lfsr <= lfsr_p;
    

    domain(0) <= '1' when (incomplete = '1' or empty_msg = '1') and state_p = MSG_NONCE else '0';
    domain(1) <= '1' when (incomplete = '1' or empty_ad = '1') and state_p = NONCE else '0';
    domain(2) <= '1' when state_p = MSG or state_p = MSG_NONCE or state_p = TAG else '0';
    domain(3) <= '1' when state_p = AD_ODD or state_p = AD_EVEN or state_p = NONCE else '0';
    domain(4) <= '1' when state_p = NONCE or (state_p = MSG_NONCE and last_block = '1') else '0';

    tag_sel <= '0' when state_p = AD_ODD or state_p = MSG else '1';
    rho_sel <= '1' when state_p = TAG else '0';
    tweak_sel <= '1' when state_p = AD_ODD or state_p = AD_EVEN else '0';
    state_sel <= '0' when first_block_p else '1';


    tag_clk_en <= '0' when state_p = AD_ODD or state_p = MSG or (core_done = '1' and (state_p = AD_EVEN or state_p = NONCE or state_p = MSG_NONCE)) else '1';

    tag_ready <= '1' when state_p = TAG else '0';
    cipher_ready <= '1' when state_p = MSG else '0';
    read_block <= '1' when (state_p = INIT and empty_ad = '0') or (state_p = AD_ODD and last_block = '0') or (core_done = '1' and ((state_p = MSG_NONCE and last_block = '0') or (state_p = AD_EVEN and last_block = '0') or (state_p = NONCE and empty_msg ='0'))) else '0';
    -- check again

    aead_done <= '1' when state_p = TAG else '0';

    lfsr_0 : entity WORK.lfsr56 port map(lfsr_p, lfsr_plus_one);

    

 state_reg : process(clk, reset)
    begin
        if reset = '0' then
            state_p <= INIT;
            core_reset <= '0';
        elsif rising_edge(clk) then
            state_p <= state_n;
            lfsr_p <= lfsr_n;
            core_reset <= core_reset_n;
            first_block_p <= first_block_n;
        end if;
    end process;

    fsm : process(state_p, core_done, last_block, empty_ad, empty_msg, lfsr_p, lfsr_plus_one, first_block_p)
    begin
        -- default 
        state_n <= state_p; 
        lfsr_n <= lfsr_p;
        core_reset_n <= '1';
        first_block_n <= first_block_p;
        case state_p is
            when INIT =>
                first_block_n <= true;
                lfsr_n <= LFSR_ZERO;
                core_reset_n <= '0';
                if empty_ad = '1' then
                    lfsr_n <= LFSR_ONE;
                    state_n <= NONCE;
                else
                    state_n <= AD_ODD;
                end if;
                
            when AD_ODD =>
                core_reset_n <= '0';
                lfsr_n <= lfsr_plus_one;
                state_n <= AD_EVEN;
                first_block_n <= false;
                if last_block = '1' then
                    state_n <= NONCE;
                end if;

            when AD_EVEN =>
                if core_done = '1' then
                    lfsr_n <= lfsr_plus_one;
                    state_n <= AD_ODD;
                    if last_block = '1' then
                        core_reset_n <= '0';
                        state_n <= NONCE;
                    end if;
                end if;

            when NONCE =>
                if core_done = '1' then
                    first_block_n <= false;
                    lfsr_n <= LFSR_ONE;
                    if empty_msg = '1' then
                        state_n <= MSG_NONCE;
                        core_reset_n <= '0';
                    else
                        state_n <= MSG;
                    end if;
                end if;


            when MSG =>
                state_n <= MSG_NONCE;
                core_reset_n <= '0';

            when MSG_NONCE =>
                if core_done = '1' then
                    lfsr_n <= lfsr_plus_one;
                    if last_block = '1' then
                        state_n <= TAG;
                    else 
                        state_n <= MSG;
                    end if;
                end if;

            when TAG =>
                state_n <= DONE;

            when others => -- including DONE
                state_n <= DONE;
                
        end case;
    end process;

end;

