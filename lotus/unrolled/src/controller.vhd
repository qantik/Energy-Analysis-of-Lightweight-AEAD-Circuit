library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port (clk          : in std_logic;
          reset        : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;
          empty_ad     : in std_logic;
          empty_msg    : in std_logic;

          mode           : out std_logic_vector(2 downto 0);
          tweak          : out std_logic_vector(3 downto 0);
          nonce_delta_en : out std_logic;
          v_delta_en     : out std_logic;
          w_delta_en     : out std_logic;
          l_delta_en     : out std_logic;
          l_delta_load   : out std_logic;
          load_key       : out std_logic;
          load_key_delta : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, init_0, init_1, ad, enc_0, enc_1, enc_2, enc_3, tag);
    signal state, next_state : state_type;

begin

    state_reg : process(clk, reset)
    begin
        if reset = '0' then
            state  <= start;
        elsif rising_edge(clk) then
            state  <= next_state;
        end if;
    end process;

    fsm : process(state, empty_ad, empty_msg, last_block, last_partial)
    begin

        next_state  <= state;

        mode           <= "000";
        tweak          <= "0000";
        nonce_delta_en <= '0';
        v_delta_en     <= '0';
        w_delta_en     <= '0';
        l_delta_en     <= '0';
        l_delta_load   <= '0';
        load_key       <= '0';
        load_key_delta <= '0';

        case state is
            when start =>
                next_state   <= init_0;

            when init_0 =>
                mode         <= "000";
                tweak        <= "0000";
                load_key     <= '1';
                l_delta_en   <= '1';
                l_delta_load <= '1';
                next_state   <= init_1;

            when init_1 =>
                mode           <= "001";
                tweak          <= "0001";
                load_key_delta <= '1';

                nonce_delta_en <= '1';
                if empty_ad = '1' and empty_msg = '1' then
                    next_state <= tag;
                elsif empty_ad = '1' then
                    next_state <= enc_0;
                else
                    next_state <= ad;
                end if;

            when ad =>
                mode <= "010";
                if last_partial = '1' then
                    tweak <= "0011";
                else
                    tweak <= "0010";
                end if;

                v_delta_en  <= '1';
                l_delta_en  <= '1';
                if last_block = '1' then
                    if empty_msg = '1' then
                        next_state <= tag;
                    else
                        next_state <= enc_0;
                    end if;
                else
                    next_state <= ad;
                end if;

            when enc_0 =>
                if last_block = '1' then
                    mode  <= "101";
                    tweak <= "1100";
                else
                    mode  <= "010";
                    tweak <= "0100";
                end if;
                w_delta_en <= '1';
                next_state <= enc_1; 

            when enc_1 =>
                mode       <= "001";
                next_state <= enc_2;
                if last_block = '1' then
                    tweak <= "1100";
                else
                    tweak <= "0100";
                end if;
                
            when enc_2 =>
                if last_block = '1' then
                    tweak <= "1101";
                    mode  <= "110";
                else
                    mode  <= "011";
                    tweak <= "0101";
                end if;
                
                next_state  <= enc_3;
                w_delta_en  <= '1';

            when enc_3 =>
                mode <= "001";
                if last_block = '1' then
                    tweak <= "1101";
                else
                    tweak <= "0101";
                end if;
                
                l_delta_en  <= '1';
                if last_block = '1' then
                    next_state <= tag;
                else
                    next_state <= enc_0;
                end if;

            when tag =>
                mode  <= "100";
                tweak <= "0110";

        end case;
    end process;

end behaviour;
