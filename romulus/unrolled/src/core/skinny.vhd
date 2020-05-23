library ieee;
use ieee.std_logic_1164.all;

entity skinny is
    generic (INVERSE_GATED : boolean := false);
    port (clk        : in  std_logic;
          iclk       : in  std_logic;
          key        : in  std_logic_vector (383 downto 0);
          plaintext  : in  std_logic_vector (127 downto 0);
          ciphertext : out std_logic_vector (127 downto 0));
end skinny;

architecture structural of skinny is

    constant n : integer := 128;
    constant t : integer := 384;
    constant r : integer := 56;

    signal round_tmp : std_logic_vector(((r + 1) * n) - 1 downto 0);
    signal round_key : std_logic_vector(((r + 1) * t) - 1 downto 0);
    signal inter     : std_logic_vector(((r + 1) * n) - 1 downto 0);
    signal enable    : std_logic_vector(r downto 0);

    constant round_cst : std_logic_vector(371 downto 0) := x"810A14A952A5C993264C9122448912A746ADD9B3468F1E1CB972C50A1C18B16AF5E9D3A7CF9F1EBF7EFDF9F3C70C1";
begin

    ig : if INVERSE_GATED = true generate
        round_tmp((n - 1) downto 0) <= plaintext;
        round_key((t - 1) downto 0) <= key;
        enable(0)                   <= clk;

        delay_gen : for i in 1 to (r) generate
            delay : entity work.delayer port map (enable(i-1), enable(i));
        end generate;

        comp : for i in 0 to (r - 1) generate

            inter(((i+1)*n) - 1 downto (i*n)) <= round_tmp(((i+1)*n) - 1 downto (i * n))
                                                     when (enable(i+1) or iclk) = '1'
                                                     else (others => '0');

            rf : entity work.roundfunction
                port map (clk       => clk,
                          round_cst => round_cst(((i+1)*6) - 1 downto (i*6)),
                          round_key => round_key(((i+1)*t) - 1 downto (i*t)),
                          round_in  => inter(((i+1)*n) - 1 downto (i*n)),
                          round_out => round_tmp(((i+2)*n) - 1 downto ((i+1)*n)));

            ke : entity work.keyexpansion
                port map (clk       => clk,
                          key       => round_key(((i+1)*t) - 1 downto (i*t)),
                          round_key => round_key(((i+2)*t) - 1 downto ((i+1)*t)));

        end generate;
    end generate;

    norm : if INVERSE_GATED = false generate
        round_tmp((n-1) downto 0) <= plaintext;
        round_key((t-1) downto 0) <= key;

        comp : for i in 0 to (r-1) generate
            rf : entity work.roundfunction
                port map (clk       => clk,
                          round_cst => round_cst(((i+1)*6) - 1 downto (i*6)),
                          round_key => round_key(((i+1)*T) - 1 downto (i*t)),
                          round_in  => round_tmp(((i+1)*N) - 1 downto (i*n)),
                          round_out => round_tmp(((i+2)*N) - 1 downto ((i+1)*n)));

            ke : entity work.keyexpansion
                port map (clk       => clk,
                          key       => round_key(((i+1)*t) - 1 downto (i*t)),
                          round_key => round_key(((i+2)*t) - 1 downto ((i+1)*t)));

        end generate;
    end generate;

    ciphertext <= round_tmp(((r+1)*n) - 1 downto (r*n));

end Structural;
