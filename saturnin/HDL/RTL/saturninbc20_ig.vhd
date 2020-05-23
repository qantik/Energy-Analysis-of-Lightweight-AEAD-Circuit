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

signal R,EoutxD: sigarray;
signal C,D,EC,ED: conarray;

signal Clk,ENxS: std_logic_vector(10 downto 0);

begin

PTxD<= InxDI ;


R(0)<=PTxD;
C(0)<= R0(31 downto 16);
D(0)<= R0(15 downto 0);



i0: entity srf1 (s1) port map (R(0), KeyxDI, C(0),D(0), R(1),C(1),D(1));


i1: entity srf3 (s3) port map (EoutxD(1), KeyxDI, EC(1),ED(1), R(2),C(2),D(2));


sr: for i in 2 to 5 generate


r0: entity srf1 (s1) port map (EoutxD(2*i-2), KeyxDI, EC(2*i-2),ED(2*i-2), R(2*i-1),C(2*i-1),D(2*i-1));

r1: entity srf3 (s3) port map (EoutxD(2*i-1), KeyxDI, EC(2*i-1),ED(2*i-1), R(2*i),C(2*i),D(2*i));
 
 
end generate sr;
 
 
 

 
---------------------------
loop2: for i in 2 to 10 generate  
---------------------------

    il: for j in 0 to 255 generate
       
            EoutxD(i-1)(j)  <= R(i-1)(j)  and ENxS(i);
 

    end generate il;


    cl: for j in 0 to 15 generate
       
            EC(i-1)(j)  <= C(i-1)(j)  and ENxS(i);
            ED(i-1)(j)  <= D(i-1)(j)  and ENxS(i);

    end generate cl;

 end generate loop2;

del1x: entity nBuf (nbf) port map (ClkxCI ,Clk(1));
-----------------------------------

loop3: for i in 2 to 10 generate  
---------------------------
del2x: entity Buf (bf) port map (Clk(i-1),Clk(i));
EnxS(i) <= (ClkxCI ) nand Clk(i-1);
end generate loop3;

 


 
 

OutxDO <= R(10);
  


end architecture behav;

