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

          domain_n      : out std_logic_vector(7 downto 0);
          core_reset  : out std_logic;
          auth_save   : out std_logic;
          sigma_save  : out std_logic;
          lfsr_reset  : out std_logic;
          lfsr_update : out std_logic;
          lz_n        : out std_logic;
          lsigma_n  : out std_logic;
          op_n : out std_logic;
          done_full   : out std_logic);
end;

architecture behaviour of controller is

    type state_type is (start, ad_0, ad_1, msg_0, msg_1, tag_0, tag_1);
    signal state, next_state : state_type;
    
    signal load_zero     : std_logic;
    signal load_sigma     : std_logic;
    signal out_partial     : std_logic;
    
    signal phase         : integer range 0 to 3;
    signal phase_n       : integer range 0 to 3;
   
    signal lz            : std_logic;
    signal lsigma        : std_logic;
    signal opartial      : std_logic;
    
    signal domain        : std_logic_vector(7 downto 0);
    signal domain_str    : std_logic_vector(7 downto 0);
    
    
    
    

begin

    lsigma_n <= load_sigma when phase = 0 else lsigma;
    lz_n <= load_zero when phase = 0 else lz;
    op_n <= out_partial when phase = 0 else opartial;
    domain_n <= domain when phase = 0 else domain_str;
    
    process (CLK, RESET) 
    begin
        if RESET = '0' then
            lsigma <= '0';
            lz <= '0';
            opartial <= '0';
            domain_str <= "00000010";
        elsif rising_edge(CLK) and phase = 0 then
            lsigma <= load_sigma;
            lz <= load_zero;
            opartial <= out_partial;
            domain_str <= domain;
        end if;
    end process;

    
    process (CLK)
    begin
        if state = start then
            phase <= 0;
        elsif rising_edge(CLK) then
            phase <= (phase+1) mod 4;
        end if;
    end process;
    
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

        core_reset   <= '0';
        auth_save    <= '1';
        sigma_save   <= '1';
        lfsr_reset   <= '0';
        lfsr_update  <= '0';
        load_zero    <= '0';
        load_sigma   <= '0';
        out_partial  <= '0';
        done_full    <= '0';

        domain <= "00000010";

        case state is
            when start =>
                next_state <= ad_0;
                if empty_ad = '1' and empty_msg = '1' then
                    next_state <= tag_0;
                    domain <= "00000100";
                elsif empty_ad = '1' and empty_msg = '0' then
                    domain <= "00000000";
                    next_state <= msg_0;
                end if;

            when ad_0 =>
                next_state <= ad_1;
                core_reset <= '1';
                if last_block = '1' and last_partial = '1' then
                    domain <= "00000011";
                end if;
            when ad_1 =>
                next_state <= ad_1;
                if core_done = '1' then
                    auth_save <= '0';
                    if last_block = '1' then
                        lfsr_reset <= '1';
                        if empty_msg = '1' then
                            next_state <= tag_0;
                        else
                            next_state <= msg_0;
                        end if;
                    else
                        lfsr_update <= '1';
                        next_state <= ad_0;
                    end if;
                end if;

            when msg_0 =>
                next_state <= msg_1;
                domain     <= "00000000";
                core_reset <= '1';
                sigma_save <= '0';
		if last_block = '1' then
		    if last_partial = '1' then
		    	load_zero <= '1';
                        domain    <= "00000001";
		    else
                        domain     <= "00000000";
	            end if;
                --elsif empty_msg = '1' then
                --    load_zero <= '1';
                --    domain     <= "00000100";
		end if;
            when msg_1 =>
                next_state <= msg_1;
                if core_done = '1' then
                    lfsr_update <= '1';
                    if last_partial = '1' then
                        out_partial <= '1';
                    end if;
                    if last_block = '1' then
                        next_state <= tag_0;
                    else
                        next_state <= msg_0;
                    end if;
                end if;

            when tag_0 =>
                next_state <= tag_1;
                core_reset <= '1';
                load_sigma <= '1';
                if last_partial = '1' then
                    domain     <= "00000101";
                else
                    domain     <= "00000100";
                end if;
            when tag_1 =>
                next_state <= tag_1;
                if core_done = '1' then
                    done_full <= '1';
                end if;
        end case;
    end process;

end;

