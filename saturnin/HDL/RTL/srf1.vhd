library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;


entity srf1 is
  port(
        InxDI     : in  std_logic_vector(255 downto 0);
        KeyxDI    : in  std_logic_vector(255 downto 0);
        RC0xD     : in  std_logic_vector(15 downto 0);
        RC1xD     : in  std_logic_vector(15 downto 0);
        OutxDO    : out std_logic_vector(255 downto 0);
        RC0xDN    : out std_logic_vector(15 downto 0);
        RC1xDN    : out std_logic_vector(15 downto 0)
      );

end srf1;



architecture s1 of srf1 is


signal ASBxD, AMCxD,ASB1xD, S1xD, AMC1xD,T1xD, RotxD, AC1xD: std_logic_vector(255 downto 0);

signal U0xD,U1xD : std_logic_vector(15 downto 0);

begin




s0: entity slayer (sl) port map (InxDI, ASBxD);

mc0: entity mds (m) port map (ASBxD, AMCxD);

s1: entity slayer (sl) port map (AMCxD, ASB1xD);

sh14:  entity sr1m4 (s1) port map (ASB1xD, S1xD);

mc1: entity mds (m) port map (S1xD, AMC1xD);

shi14:  entity sr1m4i (s1) port map (AMC1xD, T1xD);

OutxDO<= T1xD xor RotxD xor AC1xD;



rcon0: entity rcup0 (rc) port map (RC0xD, U0xD);
rcon1: entity rcup1 (rc) port map (RC1xD, U1xD);


l1: for i in 0 to 15 generate

RotxD(255-16*i downto 240-16*i) <= KeyxDI(244-16*i  downto 240-16*i ) & KeyxDI(255-16*i  downto 245-16*i );
end generate l1;
 
AC1xD<= U0xD(7 downto 0) & U0xD(15 downto 8) & x"0000000000000000000000000000" &  U1xD(7 downto 0) & U1xD(15 downto 8) & x"0000000000000000000000000000" ;
RC0xDN<= U0xD;
RC1xDN<= U1xD;

end architecture s1;
