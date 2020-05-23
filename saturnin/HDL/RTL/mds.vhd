library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity mds is
port ( InpxDI : in  std_logic_vector(255 downto 0);
       OupxDO : out std_logic_vector(255 downto 0));
end entity mds;


architecture m of mds is 

 
type Slicetype is array (0 to 3) of std_logic_vector(63 downto 0);
signal InxD,OpxD: Slicetype;


signal A,B,C,D,E,F,G,H,I,J,K,L: std_logic_vector(63 downto 0);

begin 


loop1: for i in 0 to 3 generate 

InxD(i) <= InpxDI(255 -64*i downto 192 -64*i);

end generate loop1;


A <= InxD(0) xor InxD(1);

x1: entity alpha (a) port map (InxD(1), B);

C <= InxD(2) xor InxD(3);

x2: entity alpha (a) port map (InxD(3), D);

E <= B xor C;

F <= A xor D;

x3: entity alpha2 (a) port map (A, G);

H <= G xor E;

x4: entity alpha2 (a) port map (C, I);

J <= I xor F;

K <= J xor E;

L <= H xor F;


OupxDO <= H &  K &  J &   L;


end architecture m;
