library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;


entity saturninbc is
  port(
        InxDI     : in  std_logic_vector(255 downto 0);
        KeyxDI    : in  std_logic_vector(255 downto 0);
        R0        : in  std_logic_vector(31 downto 0);
        ClkxCI    : in  std_logic;

        OutxDO    : out std_logic_vector(255 downto 0) 
      );

end saturninbc;


architecture behav of saturninbc is



signal PTxD  : std_logic_vector(255 downto 0);

 

 

type sigarray is array (0 to 10) of std_logic_vector(255 downto 0);
type conarray is array (0 to 10) of std_logic_vector(15 downto 0);

signal R: sigarray;
signal C,D: conarray;

begin

PTxD<= InxDI ;


R(0)<=PTxD;
C(0)<= R0(31 downto 16);
D(0)<= R0(15 downto 0);


sr: for i in 1 to 5 generate


r0: entity srf1 (s1) port map (R(2*i-2), KeyxDI, C(2*i-2),D(2*i-2), R(2*i-1),C(2*i-1),D(2*i-1));

r1: entity srf3 (s3) port map (R(2*i-1), KeyxDI, C(2*i-1),D(2*i-1), R(2*i),C(2*i),D(2*i));
 
 
end generate sr;
 
 
 

 
 

OutxDO <= R(10);
  


end architecture behav;

