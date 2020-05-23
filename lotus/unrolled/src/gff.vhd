library ieee;
use ieee.std_logic_1164.all;

entity gff is
    generic (SIZE : integer := 128);
    port(clk    : in std_logic;
         reset  : in std_logic;
         input  : in std_logic_vector(SIZE-1 downto 0);
         enable : in std_logic;

         output : out std_logic_vector(SIZE-1 downto 0));
end;

architecture behaviour of gff is

    signal state : std_logic_vector(SIZE-1 downto 0);

begin

    output <= state;

    reg : process(clk, reset)
    begin
        if reset = '0' then
            state <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                state <= input;
            end if;
        end if;
    end process;

end;
