library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity FORKSKINNY is
    generic (R : integer := 1; CLOCK_GATED : boolean := false);
    port (CLK       : in std_logic;
          RESET     : in std_logic;
          MODE      : in std_logic;
          TWEAKEY   : in std_logic_vector (287 downto 0);
          PLAINTEXT : in std_logic_vector (127 downto 0);          
          
          DONE       : out std_logic;
          CIPHERTEXT : out std_logic_vector (127 downto 0));
end FORKSKINNY;

architecture STRUCTURAL of FORKSKINNY is

    constant b                  : integer := 128;
    constant t                  : integer := 384;
    constant d                  : integer := 7;
    
    constant rinit              : integer := 25;
    constant r0                 : integer := 31;
    constant r1                 : integer := 31;
    
    -- offset values below
    constant o1                 : integer := ((rinit-1) rem R) + 1;
    constant o2                 : integer := ((rinit+r0-1) rem R) + 1;
    constant o3                 : integer := ((rinit+r0+r1-1) rem R) + 1;
    
    
    type bray is array (R+2 downto 0) of std_logic_vector(b-1 downto 0);
    type tray is array (R+2 downto 0) of std_logic_vector(t-1 downto 0);
    type dray is array (R+2 downto 0) of std_logic_vector(d-1 downto 0);
    
    signal tmp_out              : std_logic_vector(b-1 downto 0);
    signal tmp_out_branched     : std_logic_vector(b-1 downto 0);
    signal chosen_state         : std_logic_vector(b-1 downto 0);

    signal clk_en_tmp           : std_logic;
    signal sel_branch           : std_logic;
    signal sel_c1               : std_logic;
    signal operation_done       : std_logic;
       
    signal rc_end               : std_logic_vector(d-1 downto 0);
    signal rk_end               : std_logic_vector(t-1 downto 0);
    signal state_end            : std_logic_vector(b-1 downto 0);
    
    signal keys                 : tray;
    signal s_i                  : bray;
    signal s_o                  : bray;
    signal round_constant       : dray;

begin

    
    TEMP_REG : entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (CLK, clk_en_tmp, s_o(o1), tmp_out);
    
    KEY_REG : entity WORK.FF generic map (SIZE => t) port map (CLK, keys(R+1), keys(R+2));
    STATE_REG : entity WORK.FF generic map (SIZE => b) port map (CLK, s_i(R+1), s_o(R+1));
    CTR_REG : entity WORK.FF generic map (SIZE => d) port map (CLK, round_constant(R+1), round_constant(R+2));

    round_constant(1) <= "0000001"  when RESET = '0' else round_constant(R+2);
    s_i(1) <= PLAINTEXT when RESET = '0' else s_o(R+1);
    keys(1) <= TWEAKEY & (95 downto 0 => '0') when RESET = '0' else keys(R+2);
    
        
    ROUNDS: for i in 1 to R generate
        KE : entity work.KeyExpansion  port map (keys(i), keys(i+1));
        CL : entity work.round_counter  port map (round_constant(i), round_constant(i+1));
        RF : entity work.RoundFunction port map (round_constant(i), keys(i), s_i(i), s_o(i));  
        wiring_mux: if i = o2 generate
           s_i(i+1) <= chosen_state;
        end generate;
        wiring_normal: if i /= o2 generate
            s_i(i+1) <= s_o(i);
        end generate;  
    end generate;


    chosen_state <= tmp_out_branched when sel_branch = '1' else s_o(o2);
    
    BRANCH_ADD1 : entity WORK.BRANCHADD port map(tmp_out, tmp_out_branched);
    CL1 : entity work.ControlLogic generic map (R => R) port map  (RESET, CLK, MODE, clk_en_tmp, sel_branch, sel_c1, operation_done);

    CIPHERTEXT <= s_o(o2) when sel_c1 = '1' else s_o(o3);

    DONE <= operation_done;

end STRUCTURAL;
