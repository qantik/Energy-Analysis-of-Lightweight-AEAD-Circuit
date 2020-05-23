library ieee;
use ieee.std_logic_1164.all;

entity flip is
    port (clk   : in  std_logic;
          d0    : in  std_logic;
          q     : out std_logic);
end;

architecture behaviour of flip is
begin
    reg : process(clk)
    begin
        if rising_edge(clk) then
                q <= d0;
        end if;
    end process;
end;
