library ieee;
use ieee.std_logic_1164.all;

entity dff is
    port (clk   : in  std_logic;
          sel   : in  std_logic;
          d0    : in  std_logic;
          d1    : in  std_logic;
          q     : out std_logic);
end;

architecture behaviour of dff is
begin

    state : process(clk)
    begin
        if rising_edge(clk) then
            if sel = '0' then
                q <= d0;
            else
                q <= d1;
            end if;
        end if;
    end process;

end behaviour;
