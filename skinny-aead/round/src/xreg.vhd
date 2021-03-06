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
                if enable = '1' then
                    state <= input;
                end if;
            end if;
        end process;
    end generate;

    CG : if CLOCK_GATED = true generate
        clk_reg : process(clk, reset)
        begin
            if reset = '0' then
                clken <= '0';
            elsif rising_edge(clk) then
                clken <= enable;
            end if;
        end process;

        reg : process(clken, reset)
        begin
            if reset = '0' then
                state <= (others => '0');
            elsif rising_edge(clken) then
                state <= input;
            end if;
        end process;
    end generate;

end;

