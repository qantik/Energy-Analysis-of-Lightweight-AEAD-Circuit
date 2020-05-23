library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity core_tb is

    function vector_equal(a, b : std_logic_vector) return boolean is
    begin
        for i in 0 to 127 loop
            if a(i) /= b(i) then
                return false;
            end if;
        end loop;
        return true;
    end;

end;

architecture test of core_tb is

    -- Input signals.
    signal clk   : std_logic := '0';
    signal reset : std_logic;

    signal key       : std_logic_vector(127 downto 0);
    signal plaintext : std_logic_vector(127 downto 0);

    -- Output signals.
    signal done       : std_logic;
    signal ciphertext : std_logic_vector(127 downto 0);

    constant clk_period   : time := 10 ns;

    constant k0 : std_logic_vector(127 downto 0) := x"00000000000000000000000000000000";
    constant p0 : std_logic_vector(127 downto 0) := x"00000000000000000000000000000000";
    constant c0 : std_logic_vector(127 downto 0) := x"cd0bd738388ad3f668b15a36ceb6ff92";

    constant k1 : std_logic_vector(127 downto 0) := x"fedcba9876543210fedcba9876543210";
    constant p1 : std_logic_vector(127 downto 0) := x"fedcba9876543210fedcba9876543210";
    constant c1 : std_logic_vector(127 downto 0) := x"8422241a6dbf5a9346af468409ee0152";

begin

    gift : entity work.gift
        generic map (10)
        port map (clk        => clk,
                  reset      => reset,
                  key        => key,
                  plaintext  => plaintext,
                  done       => done,
                  ciphertext => ciphertext);

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test : process
    begin
        wait until rising_edge(clk);
        reset <= '1';
        key <= k0;
        plaintext <= p0;

        wait for clk_period;
        reset <= '0';

        wait until done = '1';
        wait for clk_period/2;
        assert vector_equal(ciphertext, c0) report "wrong ciphertext" severity failure;

        wait until rising_edge(clk);
        reset <= '1';
        key <= k1;
        plaintext <= p1;

        wait for clk_period;
        reset <= '0';

        wait until done = '1';
        wait for clk_period/2;
        assert vector_equal(ciphertext, c1) report "wrong ciphertext" severity failure;

        assert false report "test passed" severity failure;

    end process;

end;
