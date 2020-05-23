library ieee;
use ieee.std_logic_1164.all;

entity ff is
    generic (SIZE : integer := 128);
    port(clk    : in std_logic;
         reset  : in std_logic;
         input  : in std_logic_vector(SIZE-1 downto 0);
         output : out std_logic_vector(SIZE-1 downto 0));
end;

architecture behaviour of ff is

    signal state : std_logic_vector(SIZE-1 downto 0);

begin

    output <= state;

    reg : process(clk, reset)
    begin
        if reset = '0' then
            state <= (others => '0');
        elsif rising_edge(clk) then
            state <= input;
        end if;
    end process reg;

end architecture behaviour;
