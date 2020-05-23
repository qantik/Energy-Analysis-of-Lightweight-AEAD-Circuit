library ieee;
use ieee.std_logic_1164.all;

entity gff is
    generic (CLOCK_GATED : boolean := false;
             SIZE        : integer := 128);
    port(clk    : in std_logic;
         reset  : in std_logic;
         input  : in std_logic_vector(SIZE-1 downto 0);
         enable : in std_logic;

         output : out std_logic_vector(SIZE-1 downto 0));
end;

architecture behaviour of gff is

    constant p : integer := 32;
    constant n : integer := size / p;

    signal state : std_logic_vector(SIZE-1 downto 0);
    signal clken : std_logic_vector(n-1 downto 0);

begin

    output <= state;
    --clken <= clk and enable;

    NCG : if CLOCK_GATED = false generate
        reg : process(clk, reset)
        begin
            if reset = '0' then
                state <= (others => '0');
            elsif rising_edge(clk) then
                if enable = '0' then
                    state <= input;
                end if;
            end if;
        end process;
    end generate;

    CG : if CLOCK_GATED = true generate

        lf : for i in 0 to n-1 generate
            cgate : entity WORK.cor port map (clk, enable, clken(i));
            ff : entity work.ff
                generic map(size => p)
                port map (clken(i), reset, input((i+1)*p - 1 downto i*p), state((i+1)*p - 1 downto i*p));
            
        end generate;

        -- clk_reg : process(clk, reset)
        -- begin
        --     if reset = '0' then
        --         clken <= '0';
        --     elsif rising_edge(clk) then
        --         clken <= enable;
        --     end if;
        -- end process;

        -- reg : process(clken, reset)
        -- begin
        --     if reset = '0' then
        --         state <= (others => '0');
        --     elsif rising_edge(clken) then
        --         state <= input;
        --     end if;
        -- end process;
    end generate;

end;
