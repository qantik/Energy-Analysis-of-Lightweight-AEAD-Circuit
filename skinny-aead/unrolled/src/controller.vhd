library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port (clk          : in std_logic;
          reset        : in std_logic;
          last_block   : in std_logic;
          last_partial : in std_logic;
          empty_ad   : in std_logic;
          empty_msg  : in std_logic;

          domain      : out std_logic_vector(7 downto 0);
          auth_save   : out std_logic;
          sigma_save  : out std_logic;
          lfsr_reset  : out std_logic;
          load_zero   : out std_logic;
          load_sigma  : out std_logic;
          out_partial : out std_logic;
          done_full   : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, ad_stage, msg_stage, tag_stage);
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

    fsm : process(state, reset, last_block, empty_ad, empty_msg, last_partial)
    begin

        next_state <= state;

        auth_save    <= '0';
        sigma_save   <= '0';
        lfsr_reset   <= '0';
        load_zero    <= '0';
        load_sigma   <= '0';
        out_partial  <= '0';
        done_full    <= '0';

        domain <= "00000010";

        case state is
            when start =>
                next_state <= ad_stage;
                lfsr_reset   <= '1';
                if empty_ad = '1' and empty_msg = '1' then
                    next_state <= tag_stage;
                elsif empty_ad = '1' and empty_msg = '0' then
                    next_state <= msg_stage;
                end if;

            when ad_stage =>
                next_state <= ad_stage;
                auth_save <= '1';
                domain <= "00000010";
                if last_block = '1' then
                    lfsr_reset <= '1';
                    if last_partial = '1' then
                        domain <= "00000011";
                    end if;
                    if empty_msg = '1' then
                        next_state <= tag_stage;
                    else
                        next_state <= msg_stage;
                    end if;
                end if;

            when msg_stage =>
                sigma_save <= '1';
                if last_block = '1' then
                    next_state <= tag_stage;
                    if last_partial = '1' then
                        domain <= "00000001";
                        out_partial <= '1';
                        load_zero <= '1';
                    else
                        domain <= "00000000";
                    end if;
                else
                    next_state <= msg_stage;
                    domain <= "00000000";
                end if;

            when tag_stage =>
                next_state <= tag_stage;
                load_sigma <= '1';
                done_full  <= '1';
                if last_partial = '1' then
                    domain     <= "00000101";
                else
                    domain     <= "00000100";
                end if;
        end case;
    end process;

end;
