library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port (clk          : in std_logic;
          reset        : in std_logic;
          core_done    : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;
          empty_ad     : in std_logic;
          empty_msg    : in std_logic;
          cst          : in std_logic_vector(5 downto 0);

          mode           : out std_logic_vector(2 downto 0);
          tweak          : out std_logic_vector(3 downto 0);
          core_reset     : out std_logic;
          nonce_delta_en : out std_logic;
          v_delta_en     : out std_logic;
          w_delta_en     : out std_logic;
          l_delta_en     : out std_logic;
          l_delta_load   : out std_logic;
          load_key       : out std_logic;
          load_key_delta : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, init_0a, init_0, init_1a, init_1,
                        ad_0, ad, enc_0a, enc_0, enc_1a, enc_1, enc_2a, enc_2, enc_3a, enc_3, tag_0, tag);
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

        next_state  <= state;

        mode           <= "000";
        tweak          <= "0000";
        core_reset     <= '0';
        nonce_delta_en <= '1';
        v_delta_en     <= '1';
        w_delta_en     <= '1';
        l_delta_en     <= '1';
        l_delta_load   <= '0';
        load_key       <= '0';
        load_key_delta <= '0';

        case state is
            when start =>
                next_state   <= init_0a;
                --core_reset   <= '1';

            when init_0a =>
                mode         <= "000";
                tweak        <= "0000";
                load_key     <= '1';
                l_delta_en   <= '0';
                l_delta_load <= '1';
                core_reset   <= '1';
                next_state   <= init_0;

            when init_0 =>
                next_state   <= init_0;
                mode         <= "000";
                tweak        <= "0000";
                if core_done = '1' then
                    next_state  <= init_1a;
                end if;

            when init_1a =>
                next_state     <= init_1;
                mode           <= "001";
                tweak          <= "0001";
                load_key_delta <= '1';
                core_reset <= '1';

            when init_1 =>
                next_state     <= init_1;
                mode           <= "001";
                tweak          <= "0001";
                load_key_delta <= '1';

                if core_done = '1' then
                    nonce_delta_en <= '0';
                    if empty_ad = '1' and empty_msg = '1' then
                        next_state <= tag_0;
                    elsif empty_ad = '1' then
                        next_state <= enc_0a;
                    else
                        next_state <= ad_0;
                    end if;
                end if;

            when ad_0 =>
                next_state <= ad;
                mode       <= "010";
                core_reset <= '1';
                if last_partial = '1' then
                    tweak <= "0011";
                else
                    tweak <= "0010";
                end if;

            when ad =>
                next_state <= ad;
                mode       <= "010";
                if last_partial = '1' then
                    tweak <= "0011";
                else
                    tweak <= "0010";
                end if;

                if core_done = '1' then
                    v_delta_en  <= '0';
                    l_delta_en  <= '0';
                    if last_block = '1' then
                        if empty_msg = '1' then
                            next_state <= tag_0;
                        else
                            next_state <= enc_0a;
                        end if;
                    else
                        next_state <= ad_0;
                    end if;
                end if;

            when enc_0a =>
                next_state <= enc_0;
                core_reset <= '1';
                if last_block = '1' then
                    mode  <= "101";
                    tweak <= "1100";
                else
                    mode  <= "010";
                    tweak <= "0100";
                end if;

            when enc_0 =>
                next_state <= enc_0;
                if last_block = '1' then
                    mode  <= "101";
                    tweak <= "1100";
                else
                    mode  <= "010";
                    tweak <= "0100";
                end if;

                if core_done = '1' then
                    w_delta_en  <= '0';
                    next_state  <= enc_1a; 
                end if;

            when enc_1a =>
                next_state <= enc_1;
                mode       <= "001";
                core_reset <= '1';

                if last_block = '1' then
                    tweak <= "1100";
                else
                    tweak <= "0100";
                end if;
                
            when enc_1 =>
                next_state <= enc_1;
                mode       <= "001";

                if last_block = '1' then
                    tweak <= "1100";
                else
                    tweak <= "0100";
                end if;
                
                if core_done = '1' then
                    next_state  <= enc_2a;
                end if;

            when enc_2a =>
                next_state <= enc_2;
                core_reset <= '1';

                if last_block = '1' then
                    tweak <= "1101";
                    mode  <= "110";
                else
                    mode  <= "011";
                    tweak <= "0101";
                end if;
                
            when enc_2 =>
                next_state <= enc_2;

                if last_block = '1' then
                    tweak <= "1101";
                    mode  <= "110";
                else
                    mode  <= "011";
                    tweak <= "0101";
                end if;
                
                if core_done = '1' then
                    next_state  <= enc_3a;
                    w_delta_en  <= '0';
                end if;

            when enc_3a =>
                next_state <= enc_3;
                mode       <= "001";
                core_reset <= '1';

                if last_block = '1' then
                    tweak <= "1101";
                else
                    tweak <= "0101";
                end if;

            when enc_3 =>
                next_state <= enc_3;
                mode       <= "001";

                if last_block = '1' then
                    tweak <= "1101";
                else
                    tweak <= "0101";
                end if;
                
                if core_done = '1' then
                    l_delta_en  <= '0';
                    if last_block = '1' then
                        next_state <= tag_0;
                    else
                        next_state <= enc_0a;
                    end if;
                end if;

            when tag_0 =>
                next_state <= tag;
                mode       <= "100";
                tweak      <= "0110";
                core_reset <= '1';

            when tag =>
                next_state <= tag;
                mode       <= "100";
                tweak      <= "0110";

        end case;
    end process;

end behaviour;
