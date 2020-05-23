library ieee;
use ieee.std_logic_1164.all;

entity Gmult is
  port (
         DinxDI      : in  std_logic_vector(127 downto 0);
         gmult_sel   : in std_logic;
         DoutxDO     : out std_logic_vector(127 downto 0)
       );
end Gmult;

architecture gm of Gmult is

signal MxD,X1xD,X2xD,X7xD : std_logic_vector(7 downto 0) ;
signal LxD : std_logic_vector(127 downto 0);
signal mul2 : std_logic_vector(127 downto 0);

signal MxD1,X1xD1,X2xD1,X7xD1 : std_logic_vector(7 downto 0) ;
signal LxD1 : std_logic_vector(127 downto 0) ;
signal mul4 : std_logic_vector(127 downto 0);

begin
 
    MxD <= DinxDI(127 downto 120);
    LxD <= DinxDI(119 downto 0) & MxD;
     
    X1xD<= LxD(15 downto 8)  xor MxD;
    X2xD<= LxD(31 downto 24) xor MxD;
    X7xD<= LxD(47 downto 40) xor MxD;
   
    mul2 <= LxD(127 downto 48) & X7xD & LxD(39 downto 32) & X2xD & LxD(23 downto 16) &  X1xD & LxD(7 downto 0);
    
    MxD1 <= mul2(127 downto 120);
    LxD1 <= mul2(119 downto 0) & MxD1;
     
    X1xD1<= LxD1(15 downto 8)  xor MxD1;
    X2xD1<= LxD1(31 downto 24) xor MxD1;
    X7xD1<= LxD1(47 downto 40) xor MxD1;
   
    mul4 <= LxD1(127 downto 48) & X7xD1 & LxD1(39 downto 32) & X2xD1 & LxD1(23 downto 16) & X1xD1 & LxD1(7 downto 0);

   DoutxDO <= mul4 when gmult_sel = '0' else mul2;

end architecture gm;
 
