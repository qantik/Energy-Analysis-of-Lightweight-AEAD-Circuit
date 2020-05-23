library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity KEYEXPANSION is
    port (KEY       : in  std_logic_vector (383 downto 0);

          ROUND_KEY : out std_logic_vector (383 downto 0));
end KEYEXPANSION;

architecture BEHAVIOUR of KEYEXPANSION is

    constant W : integer := 8;
    constant N : integer := 128;
    constant T : integer := 384;

    signal key_next, key_perm : std_logic_vector((T - 1) downto 0);

begin

    P1 : entity work.Permutation
        port map (KEY ((T - 0 * N - 1) downto (T - 1 * N)), key_perm((T - 0 * N - 1) downto (T - 1 * N)));
    -- NO LFSR -----------------------------------------------------------------
    key_next((T - 0 * N - 1) downto (T - 1 * N)) <= key_perm((T - 0 * N - 1) downto (T - 1 * N));

    -- PERMUTATION -------------------------------------------------------------
    P2 : entity work.Permutation
        port map (KEY ((T - 1 * N - 1) downto (T - 2 * N)), key_perm((T - 1 * N - 1) downto (T - 2 * N)));
    -- LFSR --------------------------------------------------------------------
    LFSR2 : for i in 0 to 3 generate
        key_next((T + W * (I + 13) - 2 * N - 1) downto (T + W * (I + 12) - 2 * N)) <= key_perm((T + W * (I + 13) - 2 * N - 2) downto (T + W * (I + 12) - 2 * N)) & (key_perm(T + W * (I + 13) - 2 * N - 1) xor key_perm(T + W * (I + 13) - 2 * N - (W / 4) - 1));
        key_next((T + W * (I + 9) - 2 * N - 1) downto (T + W * (I + 8) - 2 * N))   <= key_perm((T + W * (I + 9) - 2 * N - 2) downto (T + W * (I + 8) - 2 * N)) & (key_perm(T + W * (I + 9) - 2 * N - 1) xor key_perm(T + W * (I + 9) - 2 * N - (W / 4) - 1));
        key_next((T + W * (I + 5) - 2 * N - 1) downto (T + W * (I + 4) - 2 * N))   <= key_perm((T + W * (I + 5) - 2 * N - 1) downto (T + W * (I + 4) - 2 * N));
        key_next((T + W * (I + 1) - 2 * N - 1) downto (T + W * (I + 0) - 2 * N))   <= key_perm((T + W * (I + 1) - 2 * N - 1) downto (T + W * (I + 0) - 2 * N));
    end generate;

        -- PERMUTATION -------------------------------------------------------------
    P3 : entity work.Permutation
        port map (KEY ((T - 2 * N - 1) downto (T - 3 * N)), key_perm((T - 2 * N - 1) downto (T - 3 * N)));
    -- LFSR --------------------------------------------------------------------
    LFSR3 : for I in 0 to 3 generate
        key_next((T + W * (I + 13) - 3 * N - 1) downto (T + W * (I + 12) - 3 * N)) <= (key_perm(T + W * (I + 12) - 3 * N) xor key_perm(T + W * (I + 13) - 3 * N - (W / 4))) & key_perm((T + W * (I + 13) - 3 * N - 1) downto (T + W * (I + 12) - 3 * N + 1));
        key_next((T + W * (I + 9) - 3 * N - 1) downto (T + W * (I + 8) - 3 * N))   <= (key_perm(T + W * (I + 8) - 3 * N) xor key_perm(T + W * (I + 9) - 3 * N - (W / 4))) & key_perm((T + W * (I + 9) - 3 * N - 1) downto (T + W * (I + 8) - 3 * N + 1));
        key_next((T + W * (I + 5) - 3 * N - 1) downto (T + W * (I + 4) - 3 * N))   <= key_perm((T + W * (I + 5) - 3 * N - 1) downto (T + W * (I + 4) - 3 * N));
        key_next((T + W * (I + 1) - 3 * N - 1) downto (T + W * (I + 0) - 3 * N))   <= key_perm((T + W * (I + 1) - 3 * N - 1) downto (T + W * (I + 0) - 3 * N));
    end generate;

    -- KEY OUTPUT -----------------------------------------------------------------
    ROUND_KEY <= key_next;

end BEHAVIOUR;
