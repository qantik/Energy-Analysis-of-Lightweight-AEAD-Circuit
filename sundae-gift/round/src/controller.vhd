library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port (clk          : in std_logic;
          reset        : in std_logic;
          core_done    : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;
          empty_ad     : in std_logic;
          empty_msg    : in std_logic;

          core_load  : out std_logic;
          core_gfunc : out std_logic;
          core_reset : out std_logic;
          round_comp : out std_logic;
          gmult_sel  : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, nonce, ad_0, ad, msg_0, msg, output);
    signal state, next_state : state_type;

begin

    state_reg : process(clk, reset)
    begin
        if reset = '0' then
            state <= start;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    fsm : process(state, core_done, empty_ad, empty_msg, last_block, last_partial)
    begin

        next_state <= state;

        core_load  <= '0';
        core_gfunc <= '0';
        core_reset <= '0';
        round_comp <= '0';
        gmult_sel  <= '0';

        case state is
            when start =>
                core_load  <= '1';
                core_reset <= '1';
                next_state <= nonce;

            when nonce =>
                next_state <= nonce;
                if core_done = '1' then
                    core_reset <= '1';
                    if empty_ad = '1' and empty_msg = '1' then
                        next_state <= output;
                    elsif empty_ad = '1' and empty_msg = '0' then
                        next_state <= msg_0;
                    else
                        next_state <= ad_0;
                    end if;
                end if;
                
            when ad_0 =>
                next_state <= ad;
                if last_block = '1' then
                    core_gfunc <= '1';
                    if last_partial = '1' then
                        gmult_sel <= '1';
                    end if;
                end if;
            when ad =>
                next_state <= ad;
                round_comp <= '1';
                if core_done = '1' then
                    core_reset <= '1';
                    if last_block = '1' then
                        if empty_msg = '1' then
                            next_state <= output;
                        else
                            next_state <= msg_0;
                        end if;
                    else
                        next_state <= ad_0;
                    end if;
                    
                end if;

            when msg_0 =>
                next_state <= msg;
                if last_block = '1' then
                    core_gfunc <= '1';
		    if last_partial = '1' then
                        gmult_sel <= '1';
                    end if;
                end if;
            when msg =>
                next_state <= msg;
                round_comp <= '1';
                if core_done = '1' then
                    core_reset <= '1';
                    if last_block = '1' then
                        next_state <= output;
                    else
                        next_state <= msg_0;
                    end if;
                end if;

            when output =>
                next_state <= output;
                round_comp <= '1';
                if core_done = '1' then
                    core_reset <= '1';
                end if;

        end case;
    end process;

end behaviour;
