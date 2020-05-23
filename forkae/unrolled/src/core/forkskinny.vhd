library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity FORKSKINNY is
    generic (inverse_gated : boolean := false);
    port (
          clk       : in std_logic;
          iclk      : in std_logic;
          TWEAKEY   : in std_logic_vector (287 downto 0);
          PLAINTEXT : in std_logic_vector (127 downto 0);          
          
          C0        : out std_logic_vector (127 downto 0);
          C1        : out std_logic_vector (127 downto 0)
          );
end FORKSKINNY;

architecture combinatorial of FORKSKINNY is

    constant b                  : integer := 128;
    constant t                  : integer := 384;
    constant d                  : integer := 7;
    
    constant rinit              : integer := 25;
    constant r0                 : integer := 31;
    constant r1                 : integer := 31;
    constant R                  : integer := r0 + r1 + rinit;
    
    type bray is array (R+1 downto 0) of std_logic_vector(b-1 downto 0);
    type tray is array (R+1 downto 0) of std_logic_vector(t-1 downto 0);
    type dray is array (R+1 downto 0) of std_logic_vector(d-1 downto 0);
    
    signal tmp_out_branched     : std_logic_vector(b-1 downto 0);
    
    signal keys_in              : tray;
    signal keys_out             : tray;
    
    signal s_in                 : bray;
    signal s_out                : bray;
    
    signal rc_in                : dray;
    signal rc_out               : dray;
    
    signal enable               : std_logic_vector(R-1 downto 1);

begin


        
    rc_in(1) <= "0000001";
    s_in(1) <= PLAINTEXT;
    keys_in(1) <= TWEAKEY & (95 downto 0 => '0');
    
    BUS1: for i in 1 to R generate
        KE : entity work.KeyExpansion  port map (keys_in(i), keys_out(i));
        CL : entity work.round_counter  port map (rc_in(i), rc_out(i));  
        RF : entity work.RoundFunction port map (rc_in(i), keys_in(i), s_in(i), s_out(i));       
    end generate;

    
    ig_wiring: if inverse_gated = true generate
        init_delay: entity work.delayer port map (clk, enable(1));
        delay_gen : for i in 1 to R-2 generate
            delay : entity work.delayer port map (enable(i), enable(i+1));
        end generate;
        CONNECTIONS : for i in 1 to R - 1 generate
            usual_wiring: if i /= (rinit + r0) generate
                s_in(i+1) <= (others => '0') when (enable(i) = '0' and clk = '1') else s_out(i);
            end generate;
                rc_in(i+1) <= (others => '0') when (enable(i) = '0' and clk = '1') else rc_out(i) ;
                keys_in(i+1) <= (others => '0') when (enable(i) = '0' and clk = '1') else keys_out(i);
        end generate;
        s_in(57) <= (others => '0') when (enable(56) = '0' and clk = '1') else tmp_out_branched;
    end generate;
    
    normal_wiring: if inverse_gated = false generate
        CONNECTIONS : for i in 1 to R-1 generate
            usual_wiring: if i /= (rinit + r0) generate
                s_in(i+1) <= s_out(i);
            end generate;
            rc_in(i+1) <= rc_out(i);
            keys_in(i+1) <= keys_out(i);
        end generate;
        s_in(57) <= tmp_out_branched;
    end generate;
    
    BRANCH_ADD1 : entity WORK.BRANCHADD port map(s_out(25), tmp_out_branched);

    C1 <= s_out(56);
    C0 <= s_out(87);

    


end combinatorial;
