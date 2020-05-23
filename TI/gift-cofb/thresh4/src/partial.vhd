library ieee;
use ieee.std_logic_1164.all;

entity partial is
    port (clk            : in std_logic;
          round_cst      : in std_logic_vector(5 downto 0);
          round_key      : in std_logic_vector(127 downto 0);
          x1, x2, x3, x4 : in std_logic_vector(127 downto 0);
          y1, y2, y3, y4 : out std_logic_vector(127 downto 0));
end entity partial;

architecture parallel of partial is 
 
    signal tmp1, tmp2, tmp3, tmp4     : std_logic_vector(127 downto 0);
    --signal g1o, g2o, g3o          : std_logic_vector(127 downto 0);
    --signal f1o, f2o, f3o          : std_logic_vector(127 downto 0);
    signal perm1, perm2, perm3, perm4 : std_logic_vector(127 downto 0);

begin 

    --tmp_regs : process(clk)
    --begin
    --    if rising_edge(clk) then
    --        tmp1 <= g1o;
    --        tmp2 <= g2o;
    --        tmp3 <= g3o;
    --    end if;
    --end process;
    
    --sl1: entity Slayer1 (sl) port map (Reg1xDP,Reg2xDP,Reg3xDP, SxD);
    --sl2: entity Slayer2 (sl) port map (RegxDP, Reg2xDP,Reg3xDP, S1xD);
    --sl3: entity Slayer3 (sl) port map (RegxDP, Reg1xDP,Reg3xDP, S2xD);
    --sl4: entity Slayer4 (sl) port map (RegxDP, Reg1xDP,Reg2xDP, S3xD);

    sl1 : entity work.slayer1 port map(x2, x3, x4, tmp1);
    sl2 : entity work.slayer2 port map(x1, x3, x4, tmp2);
    sl3 : entity work.slayer3 port map(x1, x2, x4, tmp3);
    sl4 : entity work.slayer4 port map(x1, x2, x3, tmp4);

    pl1 : entity work.permutation port map(tmp1, perm1);
    pl2 : entity work.permutation port map(tmp2, perm2);
    pl3 : entity work.permutation port map(tmp3, perm3);
    pl4 : entity work.permutation port map(tmp4, perm4);

    kl : entity work.keymixing port map(round_cst, round_key, perm1, y1);
    y2 <= perm2;
    y3 <= perm3;
    y4 <= perm4;
    
    --gl1: entity work.Glayer1 (gl) port map (x2, x3, g1o);
    --gl2: entity work.Glayer2 (gl) port map (x1, x3, g2o);
    --gl3: entity work.Glayer3 (gl) port map (x1, x2, g3o);

    --fl1: entity work.Flayer1 (fl) port map (tmp2, tmp3, f1o);
    --fl2: entity work.Flayer2 (fl) port map (tmp1, tmp3, f2o);
    --fl3: entity work.Flayer3 (fl) port map (tmp1, tmp2, f3o);

    -- gl1: entity Glayer1 (gl) port map (Reg1xDP,Reg2xDP , GxD);
    -- gl2: entity Glayer2 (gl) port map (RegxDP, Reg2xDP , G1xD);
    -- gl3: entity Glayer3 (gl) port map (RegxDP, Reg1xDP , G2xD);

    -- mr01 : entity Sreg (sr) port map (GxD ,ClkxCI, GxDP);
    -- mr02 : entity Sreg (sr) port map (G1xD,ClkxCI, G1xDP);
    -- mr03 : entity Sreg (sr) port map (G2xD,ClkxCI, G2xDP);

    -- fl1: entity Flayer1 (fl) port map (G1xDP,G2xDP , SxD);
    -- fl2: entity Flayer2 (fl) port map (GxDP, G2xDP , S1xD);
    -- fl3: entity Flayer3 (fl) port map (GxDP, G1xDP , S2xD);


end architecture parallel;
