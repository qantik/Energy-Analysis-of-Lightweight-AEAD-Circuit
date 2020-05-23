library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity cmix is
  
  port (
    InpxDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end cmix;


architecture cm of cmix is


signal X0xD, X1xD, X2xD, X3xD: std_logic ;
signal X03xD, X12xD          : std_logic ;
signal Y0xD, Y1xD, Y2xD, Y3xD: std_logic ;
  
begin   

 X0xD <= InpxDI(3); X1xD <= InpxDI(2); X2xD <= InpxDI(1); X3xD <= InpxDI(0);
 
 X12xD <= X1xD xor X2xD;
 X03xD <= X0xD xor X3xD;
 
 Y0xD <= X3xD xor X12xD;
 Y1xD <= X2xD xor X03xD;
 Y2xD <= X1xD xor X03xD;
 Y3xD <= X0xD xor X12xD;   
 
 OupxDO <= Y0xD & Y1xD & Y2xD & Y3xD; 
  

end architecture cm;
 
