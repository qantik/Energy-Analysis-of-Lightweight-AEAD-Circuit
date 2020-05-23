library ieee;
use ieee.std_logic_1164.all;

entity xreg is
    port(clk    : in std_logic;
         reset  : in std_logic;
         enable : in std_logic;
         input  : in std_logic_vector(127 downto 0);

         output : out std_logic_vector(127 downto 0));
end;

architecture behaviour of xreg is
begin

    reg : process(clk, reset)
    begin
        if reset = '0' then
            output <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= input;
            end if;
        end if;
    end process;

end;

