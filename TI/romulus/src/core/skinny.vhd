library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SKINNY_TH is
    port (CLK       : in std_logic;
          RESET     : in std_logic;
          KEY       : in std_logic_vector (383 downto 0);
          PT1       : in std_logic_vector (127 downto 0);
          PT2       : in std_logic_vector (127 downto 0);
          PT3       : in std_logic_vector (127 downto 0);

          DONE      : out std_logic;
          CT1       : out std_logic_vector (127 downto 0);
          CT2       : out std_logic_vector (127 downto 0);
          CT3       : out std_logic_vector (127 downto 0)
          );
end SKINNY_TH;

architecture STRUCTURAL of SKINNY_TH is

    constant b : integer := 128;
    constant t : integer := 384;
    constant d : integer := 6;
    constant w : integer := 8;
    constant n : integer := 128;

    signal round_key     : std_logic_vector(383 downto 0);
    signal round_cst     : std_logic_vector(5 downto 0);

    signal round_state1  : std_logic_vector(127 downto 0);
    signal round_state2  : std_logic_vector(127 downto 0);
    signal round_state3  : std_logic_vector(127 downto 0);

    signal domains       : std_logic_vector(2*d-1 downto 0);
    signal keys          : std_logic_vector(2*t-1 downto 0);
    
    signal states1       : std_logic_vector(2*b-1 downto 0);
    signal states2       : std_logic_vector(2*b-1 downto 0);
    signal states3       : std_logic_vector(2*b-1 downto 0);
    
    signal phase         : integer range 0 to 3;
    signal phase_n       : integer range 0 to 3;
    
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
    
    
begin


    internalClk <= CLK or clk_en;
    clk_en <= '0' when phase = 3 else '1';
    
    internalRst_n <= '0' when (RESET = '0' or (internalRst = '0' and phase < 3)) else '1';
    
    process (CLK) 
    begin
        if rising_edge(CLK) then
            internalRst <= internalRst_n;
        end if;
    end process;
    
    DOM_REG : entity WORK.SCANFF generic map (SIZE => d) port map (internalClk, domains(2*d-1 downto d), domains(d-1 downto 0));
    --KEY_REG : entity WORK.SCANFF generic map (SIZE => t) port map (internalClk, keys(2*t-1 downto t), keys(t-1 downto 0));
    
    KEY_REG : entity WORK.cg_reg_384 port map (CLK, clk_en, keys(2*t-1 downto t), keys(t-1 downto 0));
    
    --STATE_REG1 : entity WORK.SCANFF generic map (SIZE => b) port map (CLK, states1(2*b-1 downto b), states1(b-1 downto 0));
    --STATE_REG2 : entity WORK.SCANFF generic map (SIZE => b) port map (CLK, states2(2*b-1 downto b), states2(b-1 downto 0));
    --STATE_REG3 : entity WORK.SCANFF generic map (SIZE => b) port map (CLK, states3(2*b-1 downto b), states3(b-1 downto 0));


    states1(b-1 downto 0) <= states1(2*b-1 downto b);
    states2(b-1 downto 0) <= states2(2*b-1 downto b);
    states3(b-1 downto 0) <= states3(2*b-1 downto b);
    
    round_cst   <= "000000"  when internalRst = '0' else domains(d-1 downto 0);
    round_key   <= KEY       when internalRst = '0' else keys(t-1 downto 0);
    
    round_state1 <= PT1; -- when RESET = '0' else states1(b-1 downto 0);
    round_state2 <= PT2; -- when RESET = '0' else states2(b-1 downto 0);
    round_state3 <= PT3; -- when RESET = '0' else states3(b-1 downto 0);

    KE1 : entity work.KeyExpansion port map (round_key, keys(2*t-1 downto t));
    CL1 : entity work.ControlLogic port map (round_cst, domains(2*d-1 downto d));
    
    -- round function begin
        sbox_th1_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th1 port map(round_state1((w * (i + 1) - 1) downto (w * i)),
                                              round_state2((w * (i + 1) - 1) downto (w * i)),
                                              round_state3((w * (i + 1) - 1) downto (w * i)),
                                              substitute_f_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_f_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_f_3((w * (i + 1) - 1) downto (w * i)));
        end generate;
        sbox_th2_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th2 port map(round_state1((w * (i + 1) - 1) downto (w * i)),
                                              round_state2((w * (i + 1) - 1) downto (w * i)),
                                              round_state3((w * (i + 1) - 1) downto (w * i)),
                                              substitute_g_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_g_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_g_3((w * (i + 1) - 1) downto (w * i)));
        end generate;
        sbox_th3_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th3 port map(round_state1((w * (i + 1) - 1) downto (w * i)),
                                              round_state2((w * (i + 1) - 1) downto (w * i)),
                                              round_state3((w * (i + 1) - 1) downto (w * i)),
                                              substitute_h_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_h_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_h_3((w * (i + 1) - 1) downto (w * i)));
        end generate;
        sbox_th4_0 : for i in 0 to 15 generate
            S : entity WORK.sbox_th4 port map(round_state1((w * (i + 1) - 1) downto (w * i)),
                                              round_state2((w * (i + 1) - 1) downto (w * i)),
                                              round_state3((w * (i + 1) - 1) downto (w * i)),
                                              substitute_i_1((w * (i + 1) - 1) downto (w * i)),
                                              substitute_i_2((w * (i + 1) - 1) downto (w * i)),
                                              substitute_i_3((w * (i + 1) - 1) downto (w * i)));
        end generate;

        KA1 : entity WORK.KEYMIXING port map (domains(2*d-1 downto d), round_key, substitute_i_1, addition1);
        KA2 : entity WORK.KEYMIXING port map (domains(2*d-1 downto d), round_key, substitute_i_2, addition2);
        KA3 : entity WORK.KEYMIXING port map (domains(2*d-1 downto d), round_key, substitute_i_3, addition3);
        
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
                 states1(2*b-1 downto b) <= substitute_f_1;
                 states2(2*b-1 downto b) <= substitute_f_2;
                 states3(2*b-1 downto b) <= substitute_f_3;
             when 1 =>
                 states1(2*b-1 downto b) <= substitute_g_1;
                 states2(2*b-1 downto b) <= substitute_g_2;
                 states3(2*b-1 downto b) <= substitute_g_3;
             when 2 =>
                 states1(2*b-1 downto b) <= substitute_h_1;
                 states2(2*b-1 downto b) <= substitute_h_2;
                 states3(2*b-1 downto b) <= substitute_h_3;
             when others =>
                 states1(2*b-1 downto b) <= mixcolumn1;
                 states2(2*b-1 downto b) <= mixcolumn2;
                 states3(2*b-1 downto b) <= mixcolumn3;
            end case;                 
        end process;
    -- round function end 
    
    DONE       <= '1' when (domains(2*d-1 downto d) = "001010") and phase = 3 else '0';
    
    CT1 <= states1(2*b-1 downto b);
    CT2 <= states2(2*b-1 downto b);
    CT3 <= states3(2*b-1 downto b);
    
    phase <= 0 when RESET = '0' else phase_n; 
    process (CLK, phase)
    begin
        if rising_edge(CLK) then
            phase_n <= (phase+1) mod 4;
        end if;
    end process;

end STRUCTURAL;
