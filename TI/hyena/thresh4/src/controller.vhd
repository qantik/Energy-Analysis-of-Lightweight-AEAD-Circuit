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

          core_load     : out std_logic;
          delta_load    : out std_logic;
          delta_mode    : out std_logic_vector(1 downto 0);
          core_reset    : out std_logic;
          new_round     : out std_logic;
          zero_feedback : out std_logic;
          switch        : out std_logic;
          load_hyfb     : out std_logic;
          flag          : out std_logic;
          delta_save    : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, nonce, ad_0, ad, msg_0, msg);
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

        core_load     <= '0';
        delta_load    <= '0';
        delta_mode    <= "00";
        core_reset    <= '0';
        zero_feedback <= '0';
        new_round     <= '0';
        switch        <= '0';
        load_hyfb     <= '0';
        flag          <= '0';
        delta_save    <= '1';

        case state is
            when start =>
                next_state <= nonce;
                core_load  <= '1';
                core_reset <= '1';

            when nonce =>
                next_state <= nonce;
                if core_done = '1' then
                    delta_load <= '1';
                    delta_save <= '0';
                    core_reset <= '1';
                    next_state <= ad_0;
                end if;

            when ad_0 =>
                delta_save <= '0';
                if empty_ad = '1' and empty_msg = '1' then
                    delta_mode    <= "11";
                    switch        <= '1';
                    zero_feedback <= '1';
                    next_state    <= msg;
                elsif empty_ad = '1' then
                    new_round <= '1';
                    delta_mode    <= "11";
                    zero_feedback <= '1';
                    if empty_msg = '1' then
                        switch     <= '1';
                        next_state <= ad;
                    else
                        next_state <= msg;
                    end if;
                elsif last_block = '1' then
                    --new_round <= '1';
                    if last_partial = '1' then
                        delta_mode <= "11";
                    else
                        delta_mode <= "10";
                    end if;
                    if empty_msg = '1' then
                        switch     <= '1';
                        next_state <= msg;
                        --delta_mode <= "11";
                        delta_mode <= "10";
                    else
                        next_state <= ad;
                    	new_round <= '1';
                        --delta_mode <= "10";
                    end if;
                else
                    new_round <= '1';
                    next_state <= ad;
                    delta_mode <= "01";
                end if;
            when ad =>
                next_state <= ad;
                if core_done = '1' then
                    core_reset <= '1';
                    next_state <= ad_0;
                    if last_block = '1' then
                        next_state <= msg_0;
                    else
                        next_state <= ad_0;
                    end if;
                end if;

            when msg_0 =>
                next_state <= msg;
                new_round  <= '1';
                delta_mode <= "01";
                delta_save <= '0';
                if last_block = '1' then
                    switch    <= '1';
                    new_round <= '0';
                    if last_partial = '1' then
                        delta_mode <= "11";
                    else
                        delta_mode <= "10";
                    end if;
                end if;
            when msg =>
                next_state <= msg;
                if core_done = '1' then
                    core_reset <= '1';
                    if last_block = '0' then
                        next_state <= msg_0;
                    end if;
                end if;

        end case;
    end process;

end behaviour;
