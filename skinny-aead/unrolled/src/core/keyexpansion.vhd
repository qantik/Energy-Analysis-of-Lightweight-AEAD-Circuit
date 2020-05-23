library ieee;
use ieee.std_logic_1164.all;

entity keyexpansion is
    port (clk       : in  std_logic;
          key       : in  std_logic_vector (383 downto 0);
          round_key : out std_logic_vector (383 downto 0));
end keyexpansion;

architecture structural of keyexpansion is

    constant w : integer := 8;
    constant n : integer := 128;
    constant t : integer := 384;

    signal key_perm : std_logic_vector((t-1) downto 0);

begin

    p1 : entity work.permutation
        port map (key((t-0*N-1) downto (t-1*n)), key_perm((t-0*n-1) downto (t-1*n)));

    round_key((t-0*n-1) downto (t-1*n)) <= key_perm((t-0*n-1) downto (t-1*n));

    p2 : entity work.Permutation
        port map (key((t-1*n-1) downto (t-2*n)), key_perm((t-1*n-1) downto (t-2*n)));

    lfsr1 : for i in 0 to 3 generate
        round_key((t+w*(i+13)-2*n-1) downto (t+w*(i+12)-2*n)) <= key_perm((t+w*(i+13)-2*n-2) downto (T + W * (I + 12) - 2 * N)) & (key_perm(T + W * (I + 13) - 2 * N - 1) xor key_perm(T + W * (I + 13) - 2 * N - (W / 4) - 1));
        round_key((T + W * (I + 9) - 2 * N - 1) downto (T + W * (I + 8) - 2 * N))   <= key_perm((T + W * (I + 9) - 2 * N - 2) downto (T + W * (I + 8) - 2 * N)) & (key_perm(T + W * (I + 9) - 2 * N - 1) xor key_perm(T + W * (I + 9) - 2 * N - (W / 4) - 1));
        round_key((T + W * (I + 5) - 2 * N - 1) downto (T + W * (I + 4) - 2 * N))   <= key_perm((T + W * (I + 5) - 2 * N - 1) downto (T + W * (I + 4) - 2 * N));
        round_key((T + W * (I + 1) - 2 * N - 1) downto (T + W * (I + 0) - 2 * N))   <= key_perm((T + W * (I + 1) - 2 * N - 1) downto (T + W * (I + 0) - 2 * N));
    end generate;


    p3 : entity work.permutation
        port map (KEY((T - 2 * N - 1) downto (T - 3 * N)), key_perm((T - 2 * N - 1) downto (T - 3 * N)));

    lfsr2 : for i in 0 to 3 generate
        round_key((T + W * (I + 13) - 3 * N - 1) downto (T + W * (I + 12) - 3 * N)) <= (key_perm(T + W * (I + 12) - 3 * N) xor key_perm(T + W * (I + 13) - 3 * N - (W / 4))) & key_perm((T + W * (I + 13) - 3 * N - 1) downto (T + W * (I + 12) - 3 * N + 1));
        round_key((T + W * (I + 9) - 3 * N - 1) downto (T + W * (I + 8) - 3 * N))   <= (key_perm(T + W * (I + 8) - 3 * N) xor key_perm(T + W * (I + 9) - 3 * N - (W / 4))) & key_perm((T + W * (I + 9) - 3 * N - 1) downto (T + W * (I + 8) - 3 * N + 1));
        round_key((T + W * (I + 5) - 3 * N - 1) downto (T + W * (I + 4) - 3 * N))   <= key_perm((T + W * (I + 5) - 3 * N - 1) downto (T + W * (I + 4) - 3 * N));
        round_key((T + W * (I + 1) - 3 * N - 1) downto (T + W * (I + 0) - 3 * N))   <= key_perm((T + W * (I + 1) - 3 * N - 1) downto (T + W * (I + 0) - 3 * N));
    end generate;

end structural;
