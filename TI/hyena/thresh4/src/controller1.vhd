library ieee;
use ieee.std_logic_1164.all;

entity controller1 is
    port (clk          : in std_logic;
          reset        : in std_logic;
          core_done    : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;
          empty_ad     : in std_logic;
          empty_msg    : in std_logic;

          core_load     : out std_logic;
          delta_load    : out std_logic;
          delta_mode    : out std_logic;
          core_reset    : out std_logic;
          zero_feedback : out std_logic;
          switch        : out std_logic;
          load_hyfb     : out std_logic;
          core_en       : out std_logic);
end;

architecture behaviour of controller1 is

    type state_type is (start, nonce, pre_ad_0, pre_ad_1, pre_ad_2, ad_0, ad, pre_msg_0, pre_msg_1, pre_msg_2, msg_0, msg);
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
        delta_mode    <= '0';
        core_reset    <= '0';
        zero_feedback <= '0';
        switch        <= '0';
        load_hyfb     <= '0';
        core_en       <= '0';

        case state is
            when start =>
                next_state <= nonce;
                core_load  <= '1';
                core_reset <= '1';
        	core_en    <= '1';

            when nonce =>
                next_state <= nonce;
        	core_en    <= '1';
                if core_done = '1' then
                    delta_load <= '1';
                    next_state <= pre_ad_0;
                end if;

	    when pre_ad_0 =>
	        delta_mode <= '1';
		next_state <= pre_ad_1;
	    when pre_ad_1 =>
		if empty_ad = '1' then
		    delta_mode <= '1';
		elsif last_block = '1' then
		    delta_mode <= '1';
		end if;
		next_state <= pre_ad_2;
	    when pre_ad_2 =>
        	load_hyfb  <= '1';
                core_reset <= '1';
        	core_en    <= '1';
		if empty_ad = '1' then
		    delta_mode    <= '1';
		    zero_feedback <= '1';
		    next_state <= msg;
		    if empty_msg = '1' then
		    	next_state <= ad_0;
	            end if;
		elsif last_block = '1' then
		    if last_partial = '1' then
		    	delta_mode    <= '1';
		    end if;

                    if empty_msg = '1' then
                        --next_state <= msg;
                        next_state <= ad_0;
                    else
                        next_state <= ad_0;
                    end if;
		else
                    next_state <= ad_0;
		end if;

            when ad_0 =>
                next_state <= ad;
		core_en <= '1';
		if empty_msg = '1' then
                    switch <= '1';
		end if;
            when ad =>
                next_state <= ad;
		core_en <= '1';
                if core_done = '1' then
                    next_state <= pre_ad_0;
                    if last_block = '1' and empty_msg = '0' then
                        next_state <= pre_msg_0;
                    end if;
                end if;
	    
	    when pre_msg_0 =>
	        delta_mode <= '1';
		next_state <= pre_msg_1;
	    when pre_msg_1 =>
		next_state <= pre_msg_2;
	        if last_block = '1' then
	            delta_mode <= '1';
		end if;
	    when pre_msg_2 =>
        	load_hyfb <= '1';
		next_state <= msg_0;
                core_reset <= '1';
        	core_en    <= '1';
		if last_block = '1' and last_partial = '1' then
	            delta_mode <= '1';
		end if;

            when msg_0 =>
		core_en <= '1';
                next_state <= msg;
		if last_block = '1' then
	 	    switch <= '1';
		end if;
	    when msg =>
		core_en <= '1';
                next_state <= msg;
                if core_done = '1' then
                    core_reset <= '1';
                    if last_block = '0' then
                        next_state <= pre_msg_0;
                    end if;
                end if;

        end case;
    end process;

end behaviour;
