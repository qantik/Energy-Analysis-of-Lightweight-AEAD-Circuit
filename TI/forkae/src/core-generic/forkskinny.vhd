library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;


entity FORKSKINNY is
    generic (CLOCK_GATED : boolean := false);
    port (CLK       : in std_logic;
          RESET     : in std_logic;
          MODE      : in std_logic;
          TWEAKEY   : in std_logic_vector (287 downto 0);
          PT1       : in std_logic_vector (127 downto 0);
          PT2       : in std_logic_vector (127 downto 0);          
          PT3       : in std_logic_vector (127 downto 0);                    
          
          DONE       : out std_logic;
          CT1        : out std_logic_vector (127 downto 0);
          CT2        : out std_logic_vector (127 downto 0);
          CT3        : out std_logic_vector (127 downto 0)
          
          );
end FORKSKINNY;

architecture STRUCTURAL of FORKSKINNY is

    constant b                  : integer := 128;
    constant n                  : integer := 128;
    constant t                  : integer := 384;
    constant d                  : integer := 7;
    
    constant rinit              : integer := 25;
    constant r0                 : integer := 31;
    constant r1                 : integer := 31;
    
    constant w : integer := 8;
    
    
    type bray is array (3 downto 0) of std_logic_vector(127 downto 0);
    type tray is array (3 downto 0) of std_logic_vector(t-1 downto 0);
    type dray is array (3 downto 0) of std_logic_vector(d-1 downto 0);
    
    signal tmp_out1             : std_logic_vector(b-1 downto 0);
    signal tmp_out2             : std_logic_vector(b-1 downto 0);
    signal tmp_out3             : std_logic_vector(b-1 downto 0);
    
    signal tmp_out_branched1    : std_logic_vector(b-1 downto 0);
    signal tmp_out_branched2    : std_logic_vector(b-1 downto 0);
    signal tmp_out_branched3    : std_logic_vector(b-1 downto 0);

    signal chosen_state1        : std_logic_vector(b-1 downto 0);
    signal chosen_state2        : std_logic_vector(b-1 downto 0);
    signal chosen_state3        : std_logic_vector(b-1 downto 0);

    signal clk_en_tmp           : std_logic;
    signal sel_branch           : std_logic;
    signal sel_c1               : std_logic;
    signal operation_done       : std_logic;
       
    signal rc_end               : std_logic_vector(d-1 downto 0);
    signal rk_end               : std_logic_vector(t-1 downto 0);
    
    signal state_end1           : std_logic_vector(b-1 downto 0);
    signal state_end2           : std_logic_vector(b-1 downto 0);
    signal state_end3           : std_logic_vector(b-1 downto 0);
    
    signal keys                 : tray;
    
    signal s_i_1                : bray;
    signal s_i_2                : bray;
    signal s_i_3                : bray;
    signal s_o_1                : bray;
    signal s_o_2                : bray;
    signal s_o_3                : bray;
    
    signal round_constant       : dray;
    
    signal state_next1   : std_logic_vector((n - 1) downto 0);
    signal state_next2   : std_logic_vector((n - 1) downto 0);
    signal state_next3   : std_logic_vector((n - 1) downto 0);
    
    signal substitute_f_1: std_logic_vector((n - 1) downto 0);
    signal substitute_f_2: std_logic_vector((n - 1) downto 0);
    signal substitute_f_3: std_logic_vector((n - 1) downto 0);
    
    signal substitute_g_1: std_logic_vector((n - 1) downto 0);
    signal substitute_g_2: std_logic_vector((n - 1) downto 0);
    signal substitute_g_3: std_logic_vector((n - 1) downto 0);
    
    signal substitute_h_1: std_logic_vector((n - 1) downto 0);
    signal substitute_h_2: std_logic_vector((n - 1) downto 0);
    signal substitute_h_3: std_logic_vector((n - 1) downto 0);
    
    signal substitute_i_1: std_logic_vector((n - 1) downto 0);
    signal substitute_i_2: std_logic_vector((n - 1) downto 0);
    signal substitute_i_3: std_logic_vector((n - 1) downto 0);
    
    signal addition1     : std_logic_vector((n - 1) downto 0);
    signal addition2     : std_logic_vector((n - 1) downto 0);
    signal addition3     : std_logic_vector((n - 1) downto 0);
    
    signal shiftrows1    : std_logic_vector((n - 1) downto 0);
    signal shiftrows2    : std_logic_vector((n - 1) downto 0);
    signal shiftrows3    : std_logic_vector((n - 1) downto 0);
    
    signal mixcolumn1    : std_logic_vector((n - 1) downto 0);
    signal mixcolumn2    : std_logic_vector((n - 1) downto 0);
    signal mixcolumn3    : std_logic_vector((n - 1) downto 0);
    
    signal internalClk   : std_logic;
    signal clk_en        : std_logic;
    signal internalRst   : std_logic;
    signal internalRst_n : std_logic;
    
    signal phase_vec     : std_logic_vector(1 downto 0);
    signal phase         : integer range 0 to 3;
    signal phase_n       : integer range 0 to 3;
    
    signal r_in          : std_logic_vector(127 downto 0);
    signal r_out         : std_logic_vector(127 downto 0);

begin

    
    phase_vec <= std_logic_vector(to_unsigned(phase, 2));
    internalClk <= CLK or clk_en;
    clk_en <= '0' when phase = 3 else '1';
    
    internalRst_n <= '0' when (RESET = '0' or (internalRst = '0' and phase < 3)) else '1';
    
    process (CLK) 
    begin
        if rising_edge(CLK) then
            internalRst <= internalRst_n;
        end if;
    end process;

    
    TEMP_REG1 : entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (CLK, clk_en_tmp, s_o_1(1), tmp_out1);
    TEMP_REG2 : entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (CLK, clk_en_tmp, s_o_2(1), tmp_out2);
    TEMP_REG3 : entity WORK.treg generic map (CLOCK_GATED => CLOCK_GATED) port map (CLK, clk_en_tmp, s_o_3(1), tmp_out3);
    
    --KEY_REG : entity WORK.FF generic map (SIZE => t) port map (CLK, keys(2), keys(3));
    KEY_REG : entity WORK.cg_reg_384 port map (CLK, clk_en, keys(2), keys(3));
    
    STATE_REG1 : entity WORK.FF generic map (SIZE => b) port map (CLK, s_i_1(2), s_o_1(2));
    STATE_REG2 : entity WORK.FF generic map (SIZE => b) port map (CLK, s_i_2(2), s_o_2(2));
    STATE_REG3 : entity WORK.FF generic map (SIZE => b) port map (CLK, s_i_3(2), s_o_3(2));
    
    CTR_REG : entity WORK.FF generic map (SIZE => d) port map (internalClk, round_constant(2), round_constant(3));

    round_constant(1) <= "0000001"  when internalRst = '0' else round_constant(3);
    
    s_i_1(1) <= PT1 when RESET = '0' else s_o_1(2);
    s_i_2(1) <= PT2 when RESET = '0' else s_o_2(2);
    s_i_3(1) <= PT3 when RESET = '0' else s_o_3(2);
    
    keys(1) <= TWEAKEY & (95 downto 0 => '0') when internalRst = '0' else keys(3);
    
        
    KE : entity work.KeyExpansion  port map (keys(1), keys(2));
    CL : entity work.round_counter  port map (round_constant(1), round_constant(2));
    
    r_in <= s_i_1(1) xor s_i_2(1) xor s_i_3(1);
    r_out <= s_o_1(1)xor s_o_2(1) xor s_o_3(1);
    --RF : entity work.RoundFunction port map (round_constant(1), keys(1), s_i(1), s_o(1));  
        -- round function begin
        sbox_th1_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th1 port map(s_i_1(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_2(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_3(1)((w * (i + 1) - 1) downto (w * i)),
                                              substitute_f_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_f_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_f_3((w * (i + 1) - 1) downto (w * i)));
        end generate;
        sbox_th2_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th2 port map(s_i_1(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_2(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_3(1)((w * (i + 1) - 1) downto (w * i)),
                                              substitute_g_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_g_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_g_3((w * (i + 1) - 1) downto (w * i)));
        end generate;
        sbox_th3_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th3 port map(s_i_1(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_2(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_3(1)((w * (i + 1) - 1) downto (w * i)),
                                              substitute_h_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_h_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_h_3((w * (i + 1) - 1) downto (w * i)));
        end generate;
        sbox_th4_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th4 port map(s_i_1(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_2(1)((w * (i + 1) - 1) downto (w * i)),
                                              s_i_3(1)((w * (i + 1) - 1) downto (w * i)),
                                              substitute_i_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_i_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_i_3((w * (i + 1) - 1) downto (w * i)));
        end generate;

        KA1 : entity WORK.KEYMIXING port map (round_constant(1), keys(1), substitute_i_1, addition1);
        KA2 : entity WORK.KEYMIXING port map (round_constant(1), keys(1), substitute_i_2, addition2);
        KA3 : entity WORK.KEYMIXING port map (round_constant(1), keys(1), substitute_i_3, addition3);
        
        SR1 : entity WORK.SHIFTROWS port map (addition1, shiftrows1);
        SR2 : entity WORK.SHIFTROWS port map (addition2, shiftrows2);
        SR3 : entity WORK.SHIFTROWS port map (addition3, shiftrows3);
        
        
        MC1 : entity work.MixColumns port map (shiftrows1, mixcolumn1);
        MC2 : entity work.MixColumns port map (shiftrows2, mixcolumn2);
        MC3 : entity work.MixColumns port map (shiftrows3, mixcolumn3);
        
        process (phase, substitute_f_1, substitute_f_2, substitute_f_3, 
                        substitute_g_1, substitute_g_2, substitute_g_3,
                        substitute_h_1, substitute_h_2, substitute_h_3,
                        mixcolumn1, mixcolumn2, mixcolumn3) 
        begin
            case phase is
             when 0 =>
                 s_o_1(1) <= substitute_f_1;
                 s_o_2(1) <= substitute_f_2;
                 s_o_3(1) <= substitute_f_3;
             when 1 =>
                 s_o_1(1) <= substitute_g_1;
                 s_o_2(1) <= substitute_g_2;
                 s_o_3(1) <= substitute_g_3;
             when 2 =>
                 s_o_1(1) <= substitute_h_1;
                 s_o_2(1) <= substitute_h_2;
                 s_o_3(1) <= substitute_h_3;
             when others =>
                 s_o_1(1) <= mixcolumn1;
                 s_o_2(1) <= mixcolumn2;
                 s_o_3(1) <= mixcolumn3;
            end case;                 
        end process;
    -- round function end 
    s_i_1(2) <= chosen_state1;
    s_i_2(2) <= chosen_state2;
    s_i_3(2) <= chosen_state3;


    chosen_state1 <= tmp_out_branched1 when sel_branch = '1' else s_o_1(1);
    chosen_state2 <= tmp_out_branched2 when sel_branch = '1' else s_o_2(1);
    chosen_state3 <= tmp_out_branched3 when sel_branch = '1' else s_o_3(1);
    
    BRANCH_ADD1 : entity WORK.BRANCHADD port map(tmp_out1, tmp_out_branched1);
    BRANCH_ADD2 : entity WORK.BRANCHADD port map(tmp_out2, tmp_out_branched2);
    BRANCH_ADD3 : entity WORK.BRANCHADD port map(tmp_out3, tmp_out_branched3);
    
    CL1 : entity work.ControlLogic generic map (R => 1) port map  (RESET, CLK, MODE, phase_vec, clk_en_tmp, sel_branch, operation_done);

    CT1 <= s_o_1(1);
    CT2 <= s_o_2(1);
    CT3 <= s_o_3(1);

    DONE <= operation_done;
    
    
    phase <= 0 when RESET = '0' else phase_n; 
    process (CLK, phase)
    begin
        if rising_edge(CLK) then
            phase_n <= (phase+1) mod 4;
        end if;
    end process;

end STRUCTURAL;
