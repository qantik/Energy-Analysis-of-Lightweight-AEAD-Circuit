library ieee;
use ieee.std_logic_1164.all;

entity xreg is
    generic (CLOCK_GATED : boolean := false);
    port(clk    : in std_logic;
         reset  : in std_logic;
         enable : in std_logic;
         input  : in std_logic_vector(127 downto 0);

         output : out std_logic_vector(127 downto 0));
end;

architecture behaviour of xreg is

    signal state : std_logic_vector(127 downto 0);
    signal clken  : std_logic;

begin

    output <= state;
    --clken <= clk and enable;

    NCG : if CLOCK_GATED = false generate
        reg : process(clk, reset)
        begin
            if reset = '0' then
                state <= (others => '0');
            elsif rising_edge(clk) then
                if enable = '0' then -- NOTE: enable=0 is enabled not the other way around
                    state <= input;
                end if;
            end if;
        end process;
    end generate;

    CG : if CLOCK_GATED = true generate
        cg : entity WORK.cg_xreg generic map (SIZE => 128, PARTITION => 16) port map (clk, reset, enable, input, output);
    end generate;

end;

