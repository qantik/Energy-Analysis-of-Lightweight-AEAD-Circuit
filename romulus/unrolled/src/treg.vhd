library ieee;
use ieee.std_logic_1164.all;

entity treg is
    generic (CLOCK_GATED : boolean := false);
    port(clk    : in std_logic;
         enable : in std_logic;
         input  : in std_logic_vector(127 downto 0);

         output : out std_logic_vector(127 downto 0));
end;

architecture behaviour of treg is

    signal state : std_logic_vector(127 downto 0);

begin

    output <= state;
    --clken <= clk and enable;

    NCG : if CLOCK_GATED = false generate
        reg : process(clk)
        begin
            if rising_edge(clk) then
                if enable = '0' then -- enabled = 0 is enable, not the other way around
                    state <= input;
                end if;
            end if;
        end process;
    end generate;

    CG : if CLOCK_GATED = true generate
        cgreg : entity WORK.cg_reg generic map(SIZE => 128, PARTITION => 8) port map (clk, enable, input, output);
    end generate;

end;

