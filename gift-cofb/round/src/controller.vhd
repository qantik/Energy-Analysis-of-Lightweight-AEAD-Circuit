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
          delta_load : out std_logic;
          delta_mode : out std_logic_vector(3 downto 0);
          core_reset : out std_logic;
          delta_save : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, nonce, ad_0, ad_1, msg_0, msg_1);
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
        delta_load <= '0';
        delta_mode <= "0001";
        core_reset <= '0';
        delta_save <= '1';

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
                next_state <= ad_1;
                core_gfunc <= '1';
        	delta_save <= '0';
                if empty_ad = '1' and empty_msg = '1' then
                    delta_mode <= "1111";
                elsif empty_ad = '1' and empty_msg = '0' then
                    delta_mode <= "0111";
                elsif empty_ad = '0' and empty_msg = '1' then
                    if last_block = '1' then
                        if last_partial = '1' then
                            delta_mode <= "1111";
                        else
                            delta_mode <= "1011";
                        end if;
                    else
                        delta_mode <= "0010";
                    end if;
                elsif last_block = '1' then
                    if last_partial = '1' then
                        delta_mode <= "0111";
                    else
                        delta_mode <= "0011";
                    end if; 
                else
                    delta_mode <= "0010";
                end if;

            when ad_1 =>
                next_state <= ad_1;
                if core_done = '1' then
                    core_reset <= '1';
                    if empty_ad = '1' and empty_msg = '1' then
                        next_state <= msg_1;
                    elsif empty_ad = '1' and empty_msg = '0' then
                        next_state <= msg_0;
                    elsif last_block = '1' and empty_msg = '0' then
                        next_state <= msg_0;
                    elsif last_block = '1' and empty_msg = '1' then
                        next_state <= msg_1;
                    else
                        next_state <= ad_0;
                    end if;
                end if;

            when msg_0 =>
                next_state <= msg_1;
                core_gfunc <= '1';
        	delta_save <= '0';
                if last_block = '1' then
                    if last_partial = '1' then
                        delta_mode <= "0111";
                    else
                        delta_mode <= "0011";
                    end if;
                else
                    delta_mode <= "0010";
                end if;

            when msg_1 =>
                next_state <= msg_1;
                if core_done = '1' and last_block = '0' then
                    core_reset <= '1';
                    next_state <= msg_0;
                end if;

        end case;
    end process;

end behaviour;
