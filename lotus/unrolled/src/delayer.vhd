library ieee;
use ieee.std_logic_1164.all;

entity delayer is
    port (clk  : in  std_logic;
          dclk : out std_logic);
end;

architecture parallel of delayer is
begin

    dclk <= clk;

end;


